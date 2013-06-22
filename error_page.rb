#coding: utf-8

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
