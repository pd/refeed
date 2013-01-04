require 'rss'
require 'open-uri'

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
        puts "doing the replace ..."
        src = match[1].gsub('rss/', '').gsub('RSS', '')
        item.description = "<p><img src=\"#{src}\"></p>"
      end
    end
  end
end
