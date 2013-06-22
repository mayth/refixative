#coding:utf-8
require 'sinatra'
require 'sinatra/reloader' if development?
require 'logger'
require 'securerandom'
require 'dalli'
require 'pg'
require 'sequel'
require 'cgi/util'
require_relative 'parser'
require 'json'
require 'haml'

DIFFICULTY = [:basic, :medium, :hard]

# Setup DBs
load './db_setup.rb'

# Require Models
Dir.glob('./models/*.rb').each do |s|
  require_relative s
end

SUBMIT_DATA_EXPIRY = 1800   # 30 min.
SCORE_CACHE_EXPIRY = 86400  # 24 hours.

configure do
  # Set default values for templates
  set :haml, :format => :html5
  set :revision, `git show --format='%h' -s`.strip + `git diff --quiet HEAD || echo '+'`.strip
end

require 'music_mismatch_error.rb'
require 'no_player_error.rb'

require 'helpers.rb'

# Routings
require 'error_page.rb'
require 'register.rb'
require 'player_data.rb'
require 'team_data.rb'

get '/' do
  @player_num = Player.all.size
  @scoreset_num = Scoreset.all.size
  haml :index
end

get '/player/average.?:format?' do
  halt 503, 'Average is not available yet. Please try again later.' unless File.exists?('average.dat')
  str = IO.read('average.dat')
  obj = JSON.load(str)
  
  @page_title = '平均データ'
  format = (params[:format] || 'html').to_sym
  case format
  when :json
    str
  when :html
    haml(:average, locals: obj)
  else
    haml(:average, locals: obj)
  end
end
