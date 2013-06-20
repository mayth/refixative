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

  def get_score_data(player_id, compare_id = 0)
    player = Player.find(id: player_id)
    raise NoPlayerError, player_id.to_s unless player
    scoreset = Scoreset.find(id: player.latest_scoreset_id)
    raise 'no scores for this player.' unless scoreset
    last_updated_at = scoreset.registered_at
    scores = scoreset.score

    rival = Player.find(id: compare_id)
    raise NoPlayerError, copare_id.to_s unless rival
    rival_scoreset = Scoreset.find(id: rival.latest_scoreset_id)
    raise 'no scores for the target player.' unless rival_scoreset
    rival_last_updated_at = rival_scoreset.registered_at
    rival_scores = rival_scoreset.score

    data = CACHE.get("pls_#{player_id}_vs_#{compare_id}")
    if (!data || data[:last_updated_at] < last_updated_at || data[:rival_last_updated_at] < rival_last_updated_at)
      musics = Music.order(Sequel.desc(:added_at))
      song = Hash.new
      musics.each do |m|
        song[m.name] = {
          id: m.id,
          basic: { lv: m.basic_lv },
          medium: { lv: m.medium_lv },
          hard: { lv: m.hard_lv }
        }
      end
      stat = {
        difficulties: Hash.new,
        levels: Hash.new
      }
      DIFFICULTY.each do |diff|
        stat[:difficulties][diff] = {
          played: 0,
          achieve_vs: { win: 0, lose: 0, draw: 0 },
          miss_vs: { win: 0, lose: 0, draw: 0 },
          achieve_total: 0.0,
          achieve_ave: 0.0,
          achieve_ave_all: 0.0,
          miss_total: 0,
          miss_ave: 0.0,
          miss_ave_all: 0.0
        }
      end
      (1..11).each do |level|
        stat[:levels][level] = {
          played: 0,
          achieve_vs: { win: 0, lose: 0, draw: 0 },
          miss_vs: { win: 0, lose: 0, draw: 0 },
          achieve_total: 0.0,
          achieve_ave: 0.0,
          achieve_ave_all: 0.0,
          miss_total: 0,
          miss_ave: 0.0,
          miss_ave_all: 0.0
        }
      end
      music_stat = {
        total_musics: musics.count,
        total_tunes: musics.count * DIFFICULTY.size,
        levels: Hash.new
      }
      (1..11).each do |level|
        music_stat[:levels][level] = Music.dataset.filter(basic_lv: level).or(medium_lv: level).or(hard_lv: level).all.size
      end

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
        stat_df = stat[:difficulties][difficulty_key]
        stat_df[:played] += 1
        level = s.music.send(difficulty_key.to_s + '_lv')
        stat[:levels][level][:played] += 1
        rs = rival_scores.find{|r| r.music.name == s.music.name && r.difficulty == s.difficulty }
        rs_avail = rs != nil
        tmp = { achieve: s.achieve, miss: s.miss, rank: rank,
                achieve_diff: rs_avail ? s.achieve - rs.achieve : nil,
                miss_diff: rs_avail ? s.miss - rs.miss : nil }
        song[name][DIFFICULTY[s.difficulty]][:score] = tmp
        if rs_avail
          if tmp[:achieve_diff] == 0.0
            stat_df[:achieve_vs][:draw] += 1
          elsif tmp[:achieve_diff] > 0.0
            stat_df[:achieve_vs][:win] += 1
          else
            stat_df[:achieve_vs][:lose] += 1
          end
          if tmp[:miss_diff] == 0.0
            stat_df[:miss_vs][:draw] += 1
          elsif tmp[:miss_diff] < 0.0
            stat_df[:miss_vs][:win] += 1
          else
            stat_df[:miss_vs][:lose] += 1
          end
        end
      end
      DIFFICULTY.each do |diff|
        df = stat[:difficulties][diff]
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
        lv = stat[:levels][level]
        lv[:achieve_total] = scores.select {|v| v.music.send(DIFFICULTY[v.difficulty].to_s + '_lv') == level}.map {|v| v.achieve}.inject(:+) || 0.0
        lv[:miss_total] = scores.select {|v| v.music.send(DIFFICULTY[v.difficulty].to_s + '_lv') == level}.map {|v| v.miss}.inject(:+) || 0.0
        lv[:achieve_ave] = lv[:achieve_total] / lv[:played].to_f
        lv[:achieve_ave] = nil if lv[:achieve_ave].nan?
        lv[:achieve_ave_all] = lv[:achieve_total] / music_stat[:levels][level]
        lv[:miss_ave] = lv[:miss_total].to_f / lv[:played].to_f
        lv[:miss_ave] = nil if lv[:miss_ave].nan?
        lv[:miss_ave_all] = lv[:miss_total].to_f / music_stat[:levels][level]
      end
      stat[:total_played] = stat[:difficulties].map {|k, v| v[:played]}.inject(:+)
      achieve_total = stat[:difficulties].map {|k, v| v[:achieve_total]}.inject(:+)
      miss_total = stat[:difficulties].map {|k, v| v[:miss_total]}.inject(:+)
      stat[:achieve_ave] = achieve_total / stat[:total_played]
      stat[:achieve_ave_all] = achieve_total / (musics.count * DIFFICULTY.size)
      stat[:miss_ave] = miss_total.to_f / stat[:total_played]
      stat[:miss_ave_all] = miss_total.to_f / (musics.count * DIFFICULTY.size)

      data = {player: player, last_updated_at: last_updated_at, stat: stat, music_stat: music_stat, rival: rival, rival_last_updated_at: rival_last_updated_at, song: song}
      CACHE.add("pls_#{player_id}_vs_#{compare_id}", data, SCORE_CACHE_EXPIRY)
    end
    data
  end
end

# Routings
get '/' do
  @player_num = Player.all.size
  @scoreset_num = Scoreset.all.size
  haml :index
end

get '/register' do
  @page_title = 'スコア登録'
  haml :register_form
end

post '/register' do
  halt 400, 'profile file is not uploaded.' unless params[:profile]
  halt 400, 'music file is not uploaded.' unless params[:music]
  parser = Parser::Colette.new
  @prof = parser.parse_profile(params[:profile][:tempfile].read)
  @music = parser.parse_song(params[:music][:tempfile].read)
  @session = SecureRandom.uuid

  musics = Music.all
  @new_musics = @music.reject {|up_m| musics.any? {|db_m| db_m.name == up_m[:name]}}
  @new_musics = nil if (!@new_musics || @new_musics.empty?)

  # Get old data
  old_prof = Player.find(id: @prof[:id])
  if old_prof
    # Check updates
    old_scores = latest_scores(old_prof)
    if old_scores
      scores = Hash.new
      musics.each {|m| scores[m.name] = Hash.new}
      @music.each do |m|
        old_music = old_scores.select {|v| v.music.name == m[:name]}
        m[:scores].select {|k, v| v[:achieve]}.each do |difficulty, score|
          old_score = old_music.find {|x| x.difficulty == DIFFICULTY.index(difficulty)}
          if old_score
            # Check update
            score[:is_achieve_updated] = (old_score.achieve < score[:achieve]).to_s.to_sym
            score[:is_miss_updated] = (score[:miss] < old_score.miss).to_s.to_sym
          else
            # new played
            score[:is_achieve_updated] = :new_play
            score[:is_miss_updated] = :new_play
          end
        end
      end
    end
  end

  CACHE.add(@session, {prof: @prof, music: @music, new_musics: @new_musics}, SUBMIT_DATA_EXPIRY)

  @page_title = '登録確認'
  haml :register_confirm
end

post '/registered' do
  halt 400, 'session id is not given.' unless params[:session]
  v = CACHE.get(params[:session])
  halt 500, 'your sent data is not found. it may be expired or invalid session id is given.' unless v
  halt 400, 'profile is not sent.' unless v[:prof]
  halt 400, 'music data is not sent.' unless v[:music]
  registered_at = Time.now
  prof = v[:prof]
  music = v[:music]
  new_musics = v[:new_musics]
  # CACHE.delete(params[:session])

  # Add to DB
  if new_musics && new_musics.any?
    Music.add_musics(new_musics)
  end
  player = Player.update_or_create(prof)
  player.create_scoreset(music, registered_at)

  @player_id = prof[:id]

  if new_musics && new_musics.any?
    Thread.new { load 'average_calc.rb' }
  end

  @page_title = '登録完了'
  haml :registered
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

get /^\/player\/([0-9]{1,6})(.json|.html)?$/ do
  # parse params
  str_id = params[:captures][0]
  player_id = str_id.to_i
  format = (params[:captures][1] || params[:format] || '.html').gsub(/^\./, '').downcase.to_sym
  compare_id = (params[:compare_with] || 0).to_i

  redirect "/player/average#{format == :html ? '' : '.' + format.to_s}" if player_id == 0

  local = get_score_data(player_id, compare_id)

  @page_title = "#{local[:player].name}のプレイヤーデータ"
  case format
  when :json
    scores = nil
    filtered = params[:filtered] || 'false'
    case filtered
    when 'true', '1'
      scores = local[:song].reject {|k, v| v.all? {|diff, val| !val}}
    when 'false', '0'
      scores = local[:song]
    else
      scores = local[:song]
    end
    score_array = Array.new
    scores.each do |k, v|
      h = { name: k }
      v.each do |diff, val|
        h[diff] = val
      end
      score_array << h
    end
    prof_hash = local[:player].to_hash
    prof_hash.delete(:latest_scoreset_id)
    {profile: prof_hash, scores: score_array, stat: local[:stat], last_updated_at: local[:last_updated_at], rival_id: local[:rival].id, rival_last_updated_at: local[:rival_last_updated_at]}.to_json
  when :html
    haml(:player, locals: local)
  else
    haml(:player, locals: local)
  end
end

get /^\/player\/([0-9]{1,6})\/history\/([0-9]+)(.html)?$/ do
  @page_title = "Now Loading..."
  haml :history
end

get /^\/player\/([0-9]{1,6})\/history\/([0-9]+).json$/ do
  # parse params
  str_id = params[:captures][0]
  player_id = str_id.to_i
  str_music_id = params[:captures][1]
  music_id = str_music_id.to_i
  format = (params[:captures][2] || params[:format] || '.html').gsub(/^\./, '').downcase.to_sym

  player = Player.find(id: player_id)
  raise NoPlayerError, str_id unless player
  music = Music.find(id: music_id)
  halt 404, 'The specified music is not found.' unless music
  result = {
    player: { id: player.id, name: player.name },
    music: music.to_hash,
    record_from: nil,
    record_to: nil
  }
  achieve_hist = {basic: [], medium: [], hard: []}
  miss_hist = {basic: [], medium: [], hard: []}
  dates = []
  record_from = nil
  record_to = nil
  Scoreset.filter(player_id: player_id).order(:registered_at).each do |scoreset|
    registered_at = scoreset.registered_at.strftime('%m-%d')
    scores = scoreset.score.select{|s| s.music.id == music_id}
    if scores.any?
      if dates.last == registered_at
        dates.pop
        achieve_hist.map{|k, v| v.pop}
        miss_hist.map{|k, v| v.pop}
      end
      dates << registered_at
      added_difficulty = {basic: false, medium: false, hard: false}
      scores.each do |score|
        achieve_hist[DIFFICULTY[score.difficulty]] << score.achieve
        miss_hist[DIFFICULTY[score.difficulty]] << score.miss
        added_difficulty[DIFFICULTY[score.difficulty]] = true
      end
      added_difficulty.select{|k, v| !v}.each do |k, v|
        achieve_hist[k] << 0.0
        miss_hist[k] << -10
      end
      if dates.size > 5
        dates.shift
        achieve_hist.map{|k, v| v.shift}
        miss_hist.map{|k, v| v.shift}
      end
    end
  end
  result[:dates] = dates
  result[:achieve_hist] = achieve_hist
  result[:miss_hist] = miss_hist
  result.to_json
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
  @page_title = 'チーム一覧'
  haml :teams
end

get '/team/:id' do
  @team = Team.find(id: params[:id])
  halt 404 unless @team
  @members = Player.filter(team_id: @team.id).order(:id)
  @page_title = "#{@team.name}のチームデータ"
  haml :team
end

error MusicMismatchError do
  status 500
  e = env['sinatra.error']
  @searching_name = e.searching_name
  @found_name = e.found_name
  @page_title = '楽曲が見つかりませんでした'
  haml :music_mismatch_error
end

error NoPlayerError do
  status 404
  @id = env['sinatra.error'].message
  @page_title = 'プレイヤーが見つかりませんでした'
  haml :player_not_found
end

not_found do
  @page_title = 'ページが見つかりませんでした'
  haml :not_found
end
