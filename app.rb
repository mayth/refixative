require 'bundler/setup'
require 'sinatra'
require 'sinatra/reloader' if development?

get '/' do
  haml :index
end
