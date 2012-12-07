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
  # CACHE.delete(params[:session])

  # Add to DB
  player = Player.find(:id => @prof[:id].to_i)
  team = Team.find(:id => @prof[:team][:id])
  team = Team.new(id: @prof[:team][:id], name: @prof[:team][:name]) unless team
  if team
    team.name = @prof[:team][:name]
  end
  team.save
  if player
    player.pseudonym = @prof[:pseudonym]
    player.name = @prof[:name]
    player.comment = @prof[:comment]
    player.team = team
    player.play_count = @prof[:play_count]
    player.stamp = @prof[:stamp]
    player.onigiri = @prof[:onigiri]
    player.last_play_date = @prof[:last_play_date]
    player.last_play_shop = @prof[:last_play_shop]
  else
    player = Player.new(
      id: @prof[:id].to_i,
      pseudonym: @prof[:pseudonym],
      name: @prof[:name],
      comment: @prof[:comment],
      team: team,
      play_count: @prof[:play_count],
      stamp: @prof[:stamp],
      onigiri: @prof[:onigiri],
      last_play_date: @prof[:last_play_date],
      last_play_shop: @prof[:last_play_shop],
      latest_scoreset_id: 0)
    player.save
  end

  scoreset = Scoreset.new(
    player: player,
    registered_at: registered_at)
  scoreset.save

  scores = Array.new
  @song.each do |s|
    song_name = s[:name].gsub(/''/, '"').strip
    music = Music.find(:name => song_name)
    unless music
      (1..song_name.size-1).each do |i|
        puts "trying: #{song_name.slice(0..(song_name.size - i))}"
        music = Music.find(:name.like(song_name.slice(0..(song_name.size - i)) + '%'))
        break if music
      end
      puts "found music!" if music
      msg = "Unknown music was found: \"#{song_name}\" - "
      msg += " It may be \"#{music.name}\"" if music
      halt msg
    end
    DIFFICULTY.each do |diff, diff_num|
      if s[:scores][diff][:achieve]
        score = Score.new(
          music: music,
          scoreset: scoreset,
          difficulty: diff_num,
          achieve: s[:scores][diff][:achieve],
          miss: s[:scores][diff][:miss])
        score.save
        scores << score
      end
    end
  end

  player.latest_scoreset_id = scoreset.id
  player.save

  haml :registered
end

get '/player/:id' do
  player_id = params[:id].to_i
  p = Player.find(id: player_id)
  halt 'undefined player' unless p
  @prof = p
  haml :player
end
