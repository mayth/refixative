require 'sinatra'
require 'pg'
require 'sequel'
require 'memcache'

DB = Sequel.connect('postgres://refixative@localhost/refixative')
CACHE = MemCache.new('localhost:11211')
DB.loggers << Logger.new(STDOUT) if development?
