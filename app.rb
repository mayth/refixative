require 'sinatra'
require 'sinatra/reloader' if development?
require 'logger'
require 'securerandom'
require 'memcache'
require 'pg'
require 'sequel'
require 'cgi/util'
require_relative 'parser'
require 'haml'
require 'sass'

DIFFICULTY = {basic: 0 , medium: 1, hard: 2}

# Setup DBs
DB = Sequel.connect('postgres://refixative@localhost/refixative')
CACHE = MemCache.new 'localhost:11211'
DB.loggers << Logger.new(STDOUT) if development?

# Require Models
Dir.glob('./models/*.rb').each do |s|
  require_relative s
end

CACHE_EXPIRY = 1800 # 30 min.

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
  p @song

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
  player = Player.find(:id => prof[:id].to_i)
  team = nil
  if prof[:team]
    team = Team.find(:id => prof[:team][:id])
    team.name = prof[:team][:name] if team
    team = Team.new(id: prof[:team][:id], name: prof[:team][:name]) unless team
    team.save
  end
  if player
    player.pseudonym = prof[:pseudonym]
    player.name = prof[:name]
    player.comment = prof[:comment]
    player.team = team
    player.play_count = prof[:play_count]
    player.stamp = prof[:stamp]
    player.onigiri = prof[:onigiri]
    player.last_play_date = prof[:last_play_date]
    player.last_play_shop = prof[:last_play_shop]
  else
    player = Player.new(
      id: prof[:id].to_i,
      pseudonym: prof[:pseudonym],
      name: prof[:name],
      comment: prof[:comment],
      team: team,
      play_count: prof[:play_count],
      stamp: prof[:stamp],
      onigiri: prof[:onigiri],
      last_play_date: prof[:last_play_date],
      last_play_shop: prof[:last_play_shop],
      latest_scoreset_id: 0)
    player.save
  end

  scoreset = Scoreset.new(
    player: player,
    registered_at: registered_at)
  scoreset.save

  song.each do |s|
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
        scoreset.add_score(score)
        score.save
      end
    end
  end
  scoreset.save

  player.latest_scoreset_id = scoreset.id
  player.save

  @player_id = prof[:id]

  haml :registered
end

get '/player/:id' do
  player_id = params[:id].to_i
  player = Player.find(id: player_id)
  halt 'undefined player' unless player
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
  haml :player
end
