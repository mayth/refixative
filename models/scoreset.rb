class Scoreset < Sequel::Model
  many_to_one :player
  one_to_many :score

  def Scoreset.new_scores(player, song, registered_at)
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
        raise MusicMismatchError.new(song_name, music ? music.name : nil)
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
    scoreset
  end
end
