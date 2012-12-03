require 'sinatra'
require 'sinatra/reloader' if development?

get '/' do
  haml :index
end

get '/register' do
  haml :register_form
end
