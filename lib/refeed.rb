require 'sinatra'
require 'open-uri'
require 'rss'
require 'refeed/rewriters'

$feeds = {
  'smbc'       => ['http://feeds.feedburner.com/smbc-comics/PvLb', Refeed::Rewriter::SMBC],
  'powers'     => ['http://feeds.feedburner.com/amazingsuperpowers', Refeed::Rewriter::SuperPowers],
  'buttersafe' => ['http://feeds.feedburner.com/buttersafe', Refeed::Rewriter::Buttersafe],
  'hedges'     => ['http://feeds.feedburner.com/Truthdig/ChrisHedges', Refeed::Rewriter::Hedges],
  'taibbi'     => ['http://www.rollingstone.com/siteServices/rss/taibbiBlog', Refeed::Rewriter::Taibbi]
}

get '/refeed/:name' do
  name = params[:name]
  halt 404 unless name && $feeds[name]
  url, rewriter = $feeds[name]
  [200, {'Content-Type' => 'text/xml; charset=UTF-8'}, rewriter.new(url).refeed.to_s]
end
