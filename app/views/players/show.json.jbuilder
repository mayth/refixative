require 'time'

json.set! :profile do
  json.id         @player.pid
  json.(@player,
    :name, :pseudonym, :level, :grade, :comment, :play_count,
    :refle, :total_point, :last_play_place)
  json.last_play_datetime @player.last_play_datetime.rfc2822
  json.created_at @player.created_at.rfc2822
  json.updated_at @player.updated_at.rfc2822
end

json.set! :musics do
  json.array! @player.latest_scores do |music, score|
    json.name music.name
    json.basic_lv music.basic_lv.to_i
    json.medium_lv music.medium_lv.to_i
    json.hard_lv music.hard_lv.to_i
    json.special_lv music.special_lv.try(:to_i)
    json.set! :scores do
      score.each do |difficulty, val|
        if val
          json.set! difficulty.to_s.downcase.to_sym do
            json.(val, :achievement, :miss_count)
          end
        else
          json.set! difficulty.to_s.downcase.to_sym, nil
        end
      end
    end
  end
end