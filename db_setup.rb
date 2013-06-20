require 'logger'
require 'sinatra'
require 'pg'
require 'sequel'
require 'dalli'

DB = Sequel.connect('postgres://refixative@localhost/refixative')
CACHE = Dalli::Client.new('localhost:11215', namespace: 'rfx', compress: true)
DB.loggers << Logger.new(STDOUT) if development?
