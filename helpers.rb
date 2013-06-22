#coding: utf-8

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
