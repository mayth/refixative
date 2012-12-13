require 'sinatra'
require 'sinatra/reloader' if development?
require 'logger'
require 'securerandom'
require 'memcache'
require 'pg'
require 'sequel'
require 'cgi/util'
require_relative 'parser'
require 'json'
require 'haml'
require 'sass'

DIFFICULTY = {basic: 0 , medium: 1, hard: 2}

# Setup DBs
load './db_setup.rb'

# Require Models
Dir.glob('./models/*.rb').each do |s|
  require_relative s
end

CACHE_EXPIRY = 1800 # 30 min.

class MusicMismatchError < Exception
  def initialize(searching_name, found_name = nil)
    @searching_name = searching_name
    @found_name = found_name
  end
  attr :searching_name, :found_name
end

class NoPlayerError < Exception; end

configure do
  # Set default values for templates
  set :haml, :format => :html5
  set :sass, :style => :expanded
  set :revision, `git show --format='%h' -s` + `git diff --quiet HEAD || echo '+'`
end

helpers do
  def latest_scores(player)
    scoreset = Scoreset.find(id: player.latest_scoreset_id)
    raise 'no scores for this player.' unless scoreset
    scoreset.score
  end
end

# Routings
get '/style.css' do
  content_type 'text/css', charset: 'utf-8'
  sass :style
end

get '/' do
  @player_num = Player.all.size
  @scoreset_num = Scoreset.all.size
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

  # Get old data
  old_prof = Player.find(id: @prof[:id])
  if old_prof
    # Check updates
    old_scores = latest_scores(old_prof)
    musics = Music.dataset.all
    scores = Hash.new
    musics.each {|m| scores[m.name] = Hash.new}
    @song.each do |s|
      old_music = old_scores.select {|v| v.music.name == s[:name]}
      s[:scores].select {|k, v| v[:achieve]}.each do |difficulty, score|
        old_score = old_music.find {|x| x.difficulty == DIFFICULTY[difficulty]}
        if old_score
          # Check update
          score[:is_achieve_updated] = (old_score.achieve < score[:achieve]).to_s.to_sym
          score[:is_miss_updated] = (old_score.miss < score[:miss]).to_s.to_sym
        else
          # new played
          score[:is_achieve_updated] = :new_play
          score[:is_miss_updated] = :new_play
        end
      end
    end
  end

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
  prof = v[:prof]
  song = v[:song]
  # CACHE.delete(params[:session])

  # Add to DB
  player = Player.update_or_create(prof)
  player.create_scoreset(song, registered_at)

  @player_id = prof[:id]

  haml :registered
end

get '/player/average' do
  halt 500, 'Average is not available yet. Please try again later.' unless File.exists?('average.dat')
  obj = JSON.load(IO.read('average.dat'))
  
  format = (params[:format] || 'html').to_sym
  case format
  when :json
    obj
  when :html
    haml(:average, locals: obj)
  else
    haml(:average, locals: obj)
  end
end

get '/player/:id' do
  raise NoPlayerError if params[:id] =~ /[^0-9]/
  player_id = params[:id].to_i
  player = Player.find(id: player_id)
  raise NoPlayerError, player_id.to_s unless player
  @prof = player
  scoreset = Scoreset.find(id: player.latest_scoreset_id)
  halt 'no scores for this player.' unless scoreset
  @last_updated_at = scoreset.registered_at
  scores = scoreset.score
  musics = Music.dataset.all
  @song = Hash.new
  musics.each do |m|
    @song[m.name] = Hash.new
  end
  scores.each do |s|
    name = s.music.name
    if s.achieve < 50.0
      rank = 'C'
    elsif s.achieve < 70.0
      rank = 'B'
    elsif s.achieve < 80.0
      rank = 'A'
    elsif s.achieve < 90.0
      rank = 'AA'
    elsif s.achieve < 95.0
      rank = 'AAA'
    else
      rank = 'AAA+'
    end
    @song[name][DIFFICULTY.key(s.difficulty)] = 
      { achieve: s.achieve, miss: s.miss, rank: rank }
  end

  format = params[:format] || 'html'
  case format.downcase.to_sym
  when :json
    scores = nil
    filtered = params[:filtered] || 'false'
    case filtered
    when 'true', '1'
      scores = @song.select {|k, v| !v.empty?}
    when 'false', '0'
      scores = @song
    end
    {profile: @prof.to_hash, scores: scores}.to_json
  when :html
    haml :player
  else
    haml :player
  end
end

error MusicMismatchError do
  e = env['sinatra.error']
  @searching_name = e.searching_name
  @found_name = e.found_name
  haml :music_mismatch_error
end

error NoPlayerError do
  status 404
  @id = env['sinatra.error'].message
  haml :player_not_found
end

not_found do
  haml :not_found
end
