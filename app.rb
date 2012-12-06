require 'sinatra'
require 'sinatra/reloader' if development?
require 'logger'
require_relative 'parser'

require_relative 'db_connect'

DB.loggers << Logger.new(STDOUT)

Dir.glob('./models/*.rb').each do |s|
  puts "requires #{s}"
  require_relative s
end

configure do
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
  haml :register_confirm
end

post '/registered' do
  halt 'profile is not sent.' unless params[:prof]
  halt 'music data is not sent.' unless params[:song]
  @prof = params[:prof]
  @song = params[:song]
  haml :registered
end
