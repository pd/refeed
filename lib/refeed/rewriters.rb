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
        item.description << "<p><br><br><img src=\"#{hidden_url}\"></p>"
      end
    end
  end
end
