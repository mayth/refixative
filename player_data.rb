#coding: utf-8

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
