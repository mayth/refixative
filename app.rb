require 'sinatra'
require 'sinatra/reloader' if development?
require 'logger'
require 'securerandom'
require 'memcache'
require 'pg'
require 'sequel'
require_relative 'parser'

DIFFICULTY = {basic: 0 , medium: 1, hard: 2}

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
  registered_at = Time.now
  @prof = v[:prof]
  @song = v[:song]
  CACHE.delete(params[:session])

  # Add to DB
  player = Player.find_or_create(:id => @prof[:id].to_i)
  team = Team.find_or_create(:id => @prof[:team][:id])
  team.name = @prof[:team][:name]
  player.pseudonym = @prof[:pseudonym]
  player.name = @prof[:name]
  player.comment = @prof[:comment]
  player.team = team
  player.play_count = @prof[:play_count]
  player.stamp = @prof[:stamp]
  player.onigiri = @prof[:onigiri]
  player.last_play_date = @prof[:last_play_date]
  player.last_play_shop = @prof[:last_play_shop]

  scoreset = Scoreset.new
  scoreset.player = player
  scoreset.registered_at = registered_at
  scoreset.save

  scores = Array.new
  @song.each do |s|
    music = Music.find(:name => s[:name])
    halt "Unknown music was found: #{s[:name]}" unless music
    DIFFICULTY.each do |diff, diff_num|
      if s[:scores][diff][:achieve]
        score = Score.new
        score.music = music
        score.scoreset = scoreset
        score.difficulty = diff_num
        score.achieve = s[:scores][diff][:achieve]
        score.miss = s[:scores][diff][:miss]
        score.save
        scores << score
      end
    end
  end

  player.latest_scoreset_id = scoreset.id
  player.save

  haml :registered
end
