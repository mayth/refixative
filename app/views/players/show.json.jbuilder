json.set! :profile do
  json.id         @player.pid
  json.name       @player.name
  json.pseudonym  @player.pseudonym
  json.level      @player.level
  json.grade      @player.grade
  json.comment    @player.comment
  json.play_count @player.play_count
  json.refle      @player.refle
  json.total_point @player.total_point
  json.last_play_datetime @player.last_play_datetime
  json.last_play_place    @player.last_play_place
  json.created_at @player.created_at
  json.updated_at @player.updated_at
end

json.set! :scores do
  json.array! @player.scores.group(:music_id) do |score|
    json.name score.music.name
  end
end