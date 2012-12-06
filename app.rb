require 'sinatra'
require 'sinatra/reloader' if development?
require 'logger'
require 'securerandom'
require 'memcache'
require 'pg'
require 'sequel'
require_relative 'parser'

configure do
  # Setup DBs
  DB = Sequel.connect('postgres://localhost/refixative')
  CACHE = MemCache.new 'localhost:11211'
  DB.loggers << Logger.new(STDOUT) if development?

  # Require Models
  Dir.glob('./models/*.rb').each do |s|
    require_relative s
  end

  CACHE_EXPIRY = 1800 # 30 min.

  # Set default values for templates
  set :haml, :format => :html5
  set :sass, :style => :expanded
end

# Routings
get '/style' do
  content_type 'text/css', charset: 'utf-8'
  sass :style
end

get '/' do
  haml :index
end

get '/register' do
  haml :register_form
end

post '/register' do
  halt 'profile file is not uploaded.' unless params[:profile]
  halt 'music file is not uploaded.' unless params[:music]
  parser = Parser::Colette.new
  @prof = parser.parse_profile(params[:profile][:tempfile].read)
  @song = parser.parse_song(params[:music][:tempfile].read)
  @session = SecureRandom.uuid
  CACHE.add(@session, {prof: @prof, song: @song}, CACHE_EXPIRY)
  haml :register_confirm
end

post '/registered' do
  halt 'session id is not given.' unless params[:session]
  v = CACHE.get(params[:session])
  halt 'your sent data is not found. it may be expired or invalid session id is given.' unless v
  halt 'profile is not sent.' unless v[:prof]
  halt 'music data is not sent.' unless v[:song]
  @prof = v[:prof]
  @song = v[:song]
  CACHE.delete(params[:session])
  haml :registered
end
