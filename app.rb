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

DIFFICULTY = [:basic, :medium, :hard]

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
  set :revision, `git show --format='%h' -s`.strip + `git diff --quiet HEAD || echo '+'`.strip
end

helpers do
  def latest_scores(player)
    scoreset = Scoreset.find(id: player.latest_scoreset_id)
    return nil unless scoreset
    scoreset.score
  end
end

# Routings
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

  musics = Music.all
  @new_musics = @song.reject {|s| musics.any? {|m| m.name == s[:name]}}
  new_musics = nil if (!new_musics || !new_musics.any?)

  # Get old data
  old_prof = Player.find(id: @prof[:id])
  if old_prof
    # Check updates
    old_scores = latest_scores(old_prof)
    if old_scores
      scores = Hash.new
      musics.each {|m| scores[m.name] = Hash.new}
      @song.each do |s|
        old_music = old_scores.select {|v| v.music.name == s[:name]}
        s[:scores].select {|k, v| v[:achieve]}.each do |difficulty, score|
          old_score = old_music.find {|x| x.difficulty == DIFFICULTY.index(difficulty)}
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
  end

  CACHE.add(@session, {prof: @prof, song: @song, new_musics: @new_musics}, CACHE_EXPIRY)

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
  new_musics = v[:new_musics]
  # CACHE.delete(params[:session])

  # Add to DB
  if new_musics
    Music.add_musics(new_musics)
  end
  player = Player.update_or_create(prof)
  player.create_scoreset(song, registered_at)

  @player_id = prof[:id]

  load 'average_calc.rb' if new_musics

  haml :registered
end

get '/player/average.?:format?' do
  halt 500, 'Average is not available yet. Please try again later.' unless File.exists?('average.dat')
  str = IO.read('average.dat')
  obj = JSON.load(str)
  
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

get /^\/player\/([0-9]{1,6})(.json|.html)?$/ do
  # parse params
  str_id = params[:captures][0]
  player_id = str_id.to_i
  format = (params[:captures][1] || params[:format] || '.html').gsub(/^\./, '').downcase.to_sym

  redirect "/player/average#{format == :html ? '' : '.' + format.to_s}" if player_id == 0

  player = Player.find(id: player_id)
  raise NoPlayerError, player_id.to_s unless player
  @prof = player
  scoreset = Scoreset.find(id: player.latest_scoreset_id)
  halt 'no scores for this player.' unless scoreset
  @last_updated_at = scoreset.registered_at
  scores = scoreset.score
  musics = Music.order(Sequel.desc(:added_at))
  @song = Hash.new
  musics.each do |m|
    @song[m.name] = {
      basic: { lv: m.basic_lv },
      medium: { lv: m.medium_lv },
      hard: { lv: m.hard_lv }
    }
  end
  @stat = {
    difficulties: Hash.new,
    levels: Hash.new
  }
  DIFFICULTY.each do |diff|
    @stat[:difficulties][diff] = {
      played: 0,
      achieve_vs_ave: { win: 0, lose: 0, draw: 0 },
      miss_vs_ave: { win: 0, lose: 0, draw: 0 },
      achieve_total: 0.0,
      achieve_ave: 0.0,
      achieve_ave_all: 0.0,
      miss_total: 0,
      miss_ave: 0.0,
      miss_ave_all: 0.0
    }
  end
  (1..11).each do |level|
    @stat[:levels][level] = {
      played: 0,
      achieve_vs_ave: { win: 0, lose: 0, draw: 0 },
      miss_vs_ave: { win: 0, lose: 0, draw: 0 },
      achieve_total: 0.0,
      achieve_ave: 0.0,
      achieve_ave_all: 0.0,
      miss_total: 0,
      miss_ave: 0.0,
      miss_ave_all: 0.0
    }
  end
  @music_stat = {
    total_musics: musics.count,
    total_tunes: musics.count * DIFFICULTY.size,
    levels: Hash.new
  }
  (1..11).each do |level|
    @music_stat[:levels][level] = Music.dataset.filter(basic_lv: level).or(medium_lv: level).or(hard_lv: level).all.size
  end

  average = JSON.load(IO.read('average.dat'))['score_average']
  # Calculate rank, average, difference from average
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
    difficulty_key = DIFFICULTY[s.difficulty]
    stat_df = @stat[:difficulties][difficulty_key]
    stat_df[:played] += 1
    level = s.music.send(difficulty_key.to_s + '_lv')
    @stat[:levels][level][:played] += 1
    ave = average[name][difficulty_key.to_s] if average[name]
    ave_avail = average.has_key?(name) && ave[:count] != 0
    tmp = { achieve: s.achieve, miss: s.miss, rank: rank,
            achieve_diff: ave_avail ? s.achieve - ave['achieve'] : nil,
            miss_diff: ave_avail ? s.miss - ave['miss'] : nil }
    @song[name][DIFFICULTY[s.difficulty]][:score] = tmp
    if ave_avail
      if tmp[:achieve_diff] == 0.0
        stat_df[:achieve_vs_ave][:draw] += 1
      elsif tmp[:achieve_diff] > 0.0
        stat_df[:achieve_vs_ave][:win] += 1
      else
        stat_df[:achieve_vs_ave][:lose] += 1
      end
      if tmp[:miss_diff] == 0.0
        stat_df[:miss_vs_ave][:draw] += 1
      elsif tmp[:miss_diff] < 0.0
        stat_df[:miss_vs_ave][:win] += 1
      else
        stat_df[:miss_vs_ave][:lose] += 1
      end
    end
  end
  DIFFICULTY.each do |diff|
    df = @stat[:difficulties][diff]
    df[:achieve_total] = scores.select {|v| v.difficulty == DIFFICULTY.index(diff) }.map {|v| v.achieve}.inject(:+) || 0.0
    df[:miss_total] = scores.select {|v| v.difficulty == DIFFICULTY.index(diff)}.map {|v| v.miss}.inject(:+) || 0.0
    df[:achieve_ave] = df[:achieve_total].to_f / df[:played].to_f
    df[:achieve_ave] = nil if df[:achieve_ave].nan?
    df[:achieve_ave_all] = df[:achieve_total].to_f / musics.count.to_f
    df[:miss_ave] = df[:miss_total].to_f / df[:played].to_f
    df[:miss_ave] = nil if df[:miss_ave].nan?
    df[:miss_ave_all] = df[:miss_total].to_f / musics.count.to_f
  end
  (1..11).each do |level|
    lv = @stat[:levels][level]
    lv[:achieve_total] = scores.select {|v| v.music.send(DIFFICULTY[v.difficulty].to_s + '_lv') == level}.map {|v| v.achieve}.inject(:+) || 0.0
    lv[:miss_total] = scores.select {|v| v.music.send(DIFFICULTY[v.difficulty].to_s + '_lv') == level}.map {|v| v.miss}.inject(:+) || 0.0
    lv[:achieve_ave] = lv[:achieve_total] / lv[:played].to_f
    lv[:achieve_ave] = nil if lv[:achieve_ave].nan?
    lv[:achieve_ave_all] = lv[:achieve_total] / @music_stat[:levels][level]
    lv[:miss_ave] = lv[:miss_total].to_f / lv[:played].to_f
    lv[:miss_ave] = nil if lv[:miss_ave].nan?
    lv[:miss_ave_all] = lv[:miss_total].to_f / @music_stat[:levels][level]
  end
  @stat[:total_played] = @stat[:difficulties].map {|k, v| v[:played]}.inject(:+)
  achieve_total = @stat[:difficulties].map {|k, v| v[:achieve_total]}.inject(:+)
  miss_total = @stat[:difficulties].map {|k, v| v[:miss_total]}.inject(:+)
  @stat[:achieve_ave] = achieve_total / @stat[:total_played]
  @stat[:achieve_ave_all] = achieve_total / (musics.count * DIFFICULTY.size)
  @stat[:miss_ave] = miss_total.to_f / @stat[:total_played]
  @stat[:miss_ave_all] = miss_total.to_f / (musics.count * DIFFICULTY.size)

  case format
  when :json
    scores = nil
    filtered = params[:filtered] || 'false'
    case filtered
    when 'true', '1'
      scores = @song.reject {|k, v| v.all? {|diff, val| !val}}
    when 'false', '0'
      scores = @song
    end
    score_array = Array.new
    scores.each do |k, v|
      h = { name: k }
      v.each do |diff, val|
        h[diff] = val
      end
      score_array << h
    end
    prof_hash = @prof.to_hash
    prof_hash.delete(:latest_scoreset_id)
    {profile: prof_hash, scores: score_array, stat: @stat}.to_json
  when :html
    haml :player
  else
    haml :player
  end
end

get '/teams' do
  teams = Team.order(:id)
  @teams = Array.new
  teams.each do |t|
    @teams << {
      id: t.id,
      name: t.name,
      members: Player.filter(team_id: t.id).count
    }
  end
  haml :teams
end

get '/team/:id' do
  @team = Team.find(id: params[:id])
  halt 404 unless @team
  @members = Player.filter(team_id: @team.id).order(:id)
  haml :team
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
