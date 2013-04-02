require 'rss'
require 'open-uri'
require 'nokogiri'
require 'date'

module Refeed
  def self.read_feed(url)
    RSS::Parser.parse open(url)
  end

  class Rewriter
    attr_reader :feed

    def initialize(url)
      @feed = RSS::Parser.parse(url)
    end

    def refeed
      rewrite
      feed.channel.title = "#{feed.channel.title} (refed)"
      feed
    end

    def rewrite
      raise NotImplementedError
    end
  end

  class Rewriter::SMBC < Rewriter
    def rewrite
      feed.items.each do |item|
        next unless match = item.description.match(/src="(http.+comics\/\d+\.gif)"/)
        aftercomic_url = match[1].sub('.gif', 'after.gif')
        item.description << "<br><br><br><img src=\"#{aftercomic_url}\"/>"
      end
    end
  end

  class Rewriter::SuperPowers < Rewriter
    def rewrite
      feed.items.each do |item|
        next unless match = item.description.match(/src="http.+?comics(?:-rss)?\/(\d{4}-\d{2}-\d{2})/)
        hidden_url = "http://www.amazingsuperpowers.com/hc/comics/#{match[1]}.jpg"
        extra = "<p><br><br><img src=\"#{hidden_url}\"></p>"
        item.description << extra
        item.content_encoded << extra
      end
    end
  end

  class Rewriter::Buttersafe < Rewriter
    def rewrite
      feed.items.each do |item|
        next unless match = item.description.match(/src="(.+\/comics\/rss\/.+?.jpg)"/)
        src = match[1].gsub('rss/', '').gsub('RSS', '')
        item.description = "<p><img src=\"#{src}\"></p>"
      end
    end
  end

  class Rewriter::Hedges < Rewriter
    def rewrite
      feed.items.each do |item|
        next unless url = item.guid.content
        item.guid.content = url.gsub('/report/item', '/report/print')
        content = open(item.guid.content).read
        item.description = content
        item.content_encoded = content
      end
    end
  end

  class Rewriter::Taibbi < Rewriter
    def rewrite
      feed.items.each do |item|
        next unless url = item.link
        content = open("#{url}?print=true").read
        item.content_encoded = content
      end
    end
  end

  # For when the RSS feed is non-existent or totally useless.
  class Writer
    def initialize(url)
      @html = open(url)
    end

    def doc
      @doc ||= Nokogiri @html
    end

    # Quack like Rewriter
    def refeed
      produce
      @feed
    end

    def produce
      raise NotImplementedError
    end
  end

  class Writer::ToothPaste < Writer
    def produce
      @feed = RSS::Maker.make('2.0') do |maker|
        maker.channel.author  = 'Drew Dee'
        maker.channel.updated = Time.now.to_s
        maker.channel.link    = 'http://toothpastefordinner.com'
        maker.channel.title   = 'Toothpaste For Dinner (refed)'
        maker.channel.description = 'Toothpaste For Dinner (refed)'

        imgs = doc.css('img.comic')
        imgs.each do |img|
          anchor = img.ancestors('.headertext4').css('a').first
          match  = img.attr('src').match %r[/(\d{2})(\d{2})(\d{2})/]
          date   = Date.parse("20#{match[3]}-#{match[1]}-#{match[2]}")

          maker.items.new_item do |item|
            item.link    = 'http://toothpastefordinner.com'
            item.title   = anchor.text
            item.updated = date.to_time
            item.description = img.to_s
          end
        end
      end
    end
  end
end
