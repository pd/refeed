require 'sinatra'
require 'open-uri'
require 'rss'
require 'refeed/rewriters'

$feeds = {
  'smbc' => ['http://feeds.feedburner.com/smbc-comics/PvLb', Refeed::Rewriter::SMBC]
}

get '/refeed/:name' do
  name = params[:name]
  halt 404 unless name && $feeds[name]
  url, rewriter = $feeds[name]
  [200, {'Content-Type' => 'text/xml; charset=UTF-8'}, rewriter.new(url).refeed.to_s]
end
