require 'rubygems'
require 'sinatra'
require 'nokogiri'
require 'open-uri'

DISCOGS_API_KEY = ''
LASTFM_API_KEY = '667910e60f2e9eb583f722f61dc01aab'

get %r{^/([\w\-/]+)?$} do |user|
  @user = user || 'arniemg'
  @recent = recent_tracks(@user)
  @tracks = @recent.xpath('//track')
  @last_played = @tracks.first
  @artist = @last_played.xpath('artist').first.content
  @track = @last_played.xpath('name').first.content
  @tags = top_tags(@last_played.xpath('artist').first.content)
  haml :index
end

def recent_tracks(user)
  Nokogiri::XML(open("http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=#{user}&api_key=#{LASTFM_API_KEY}"))
end

def top_tags(artist)
  Nokogiri::XML(open("http://ws.audioscrobbler.com/2.0/?method=artist.gettoptags&artist=#{URI.encode(artist)}&api_key=#{LASTFM_API_KEY}"))
end
