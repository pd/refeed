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
        comic_url = item.description.match(/src="(http.+comics\/\d+\.gif)"/)[1]
        aftercomic_url = comic_url.sub('.gif', 'after.gif')
        item.description << "<br><br><br><img src=\"#{aftercomic_url}\"/>"
      end
    end
  end
end
