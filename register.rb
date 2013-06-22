#coding: utf-8

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
