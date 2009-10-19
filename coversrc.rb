$: << File.join(File.dirname(__FILE__), 'lib')
require 'lastfm'
require 'discogs'

DISCOGS_API_KEY = '21862297af'
LASTFM_API_KEY = '667910e60f2e9eb583f722f61dc01aab'

before do
  if production?
    headers['Cache-Control'] = 'public, max-age=60'
  end
end

get '/' do
  if params[:user]
    redirect "/#{params[:user]}"
  end
  haml :index
end

get '/coversrc.css' do
  header 'Content-Type' => 'text/css; charset=utf-8'
  sass :coversrc
end

get %r{^/([\w\-/]+)?} do |user|
  if production?
    etag @user.to_etag if params[:user]
  end

  begin
    @user = User.new(user)
    @recent_tracks = @user.recent_tracks
    @lp_artist = Artist.new(@user.lp_artist)
    @search = DiscogsSearch.new(@user.lp_artist, @user.lp_track)

    haml :user
  rescue OpenURI::HTTPError
    haml :index
  end
end

helpers do
  def tag_link(tag)
    %{<a href="http://www.last.fm/tag/#{tag}">#{tag}</a>}
  end

  def artist_link(artist)
    
  end

  def pluralize(count, word)
    count == 1 ? "#{count} #{word}" : "#{count} #{word}s"
  end

  def production?
    ENV['RACK_ENV'] == 'production'
  end
end

error do
  e = request.env['sinatra.error']
  Kernel.puts e.backtrace.join("\n")
  'Application error'
end
