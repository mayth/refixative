require 'sinatra'
require 'sinatra/reloader' if development?
require 'rack/flash'
require_relative './parser'

configure do
  use Rack::Session::Cookie, :secret => IO.read('cookie_secret')
  use Rack::Flash

get '/' do
  haml :index
end

get '/register' do
  haml :register_form
end

post '/register' do
end
