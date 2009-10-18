require 'zlib'

module Gzipper
  def gzip_read(uri)
    req = open(uri, 'Accept-Encoding' => 'gzip')
    gzip = Zlib::GzipReader.new(req)
    Nokogiri::XML(gzip)
  end
end

class DiscogsRelease
  include Gzipper

  def initialize(id)
    @id = id
    uri = "http://www.discogs.com/release/#{@id}?f=xml&api_key=#{DISCOGS_API_KEY}"
    @release =  gzip_read(uri)
  end

  def id
    @id
  end

  def release
    @release
  end

  def title
    @release.xpath('//title').first.content
  end

  def image
    if uri = @release.xpath('//image').first
      uri['uri']
    end
  end

  def format
    @release.xpath('//format').first['name']
  end

end

class DiscogsSearch
  include Gzipper

  def initialize(artist, track)
    @artist, @track = URI.encode(artist), URI.encode(track)
    uri = "http://www.discogs.com/search?type=all&q=#{@artist}+#{@track}&f=xml&api_key=#{DISCOGS_API_KEY}"
    @results = gzip_read(uri)
  end

  def results
    @results.xpath('//result').map { |r| DiscogsRelease.new(r.xpath('uri').first.content.scan(/\d+$/)) }
  end

  def ids
    @results.xpath('//result').map { |r| r.xpath('uri').first.content.scan(/\d+$/) }
  end

  def self.search(artist, track)
    #images = []
    #doc.xpath('//result/uri').each do |r|
      #id = r.content.scan(/\d+$/)
      #uri = "http://www.discogs.com/release/#{id}?f=xml&api_key=#{DISCOGS_API_KEY}"
      #req = open(uri, 'Accept-Encoding' => 'gzip')
      #gzip = Zlib::GzipReader.new(req)
      #doc = Nokogiri::XML(gzip)
      ##albums = doc.xpath('//track/title').map { |t| t.content == track }
      ##unless albums.empty?
        ##images << doc.xpath('//image').map { |i| i['uri'] }
        ##images << doc.xpath('//image').first['uri']
      ##end
    #end
    #images
  end

end
