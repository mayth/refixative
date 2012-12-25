#coding:utf-8
class Scoreset < Sequel::Model
  many_to_one :player
  one_to_many :score

  def Scoreset.new_scores(player, song, registered_at)
    scoreset = Scoreset.new(
      player: player,
      registered_at: registered_at)
    scoreset.save

    song.each do |s|
      song_name = self.name_normalize(s[:name])
      music = Music.find(:name => song_name)
      unless music
        (1..song_name.size).each do |i|
          puts "trying: #{song_name.slice(0..(song_name.size - i))}"
          music = Music.find(:name.like(song_name.slice(0..(song_name.size - i)) + '%'))
          break if music
        end
        puts "found music!" if music
        if music
          puts 'DB char:'
          music.name.each_char do |char|
            p char.unpack('U*')
          end
          puts 'parsed char:'
          song_name.each_char do |char|
            p char.unpack('U*')
          end
        end
        raise MusicMismatchError.new(song_name, music ? music.name : nil)
      end
      DIFFICULTY.each do |diff|
        if s[:scores][diff][:achieve]
          score = Score.new(
            music: music,
            scoreset: scoreset,
            difficulty: DIFFICULTY.index(diff),
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

  def self.name_normalize(name)
    name.gsub(/''/, '"')  # double single quote -> double quote
        .gsub(/　/, ' ')  # full-width space -> half-width space
        .gsub(/ +/, ' ')  # continuous half-width space -> single half-width space
        .gsub(/−/, '—')  # full-width hyphen -> full-width dash
        .gsub(/—+/, '—')  # continuous full-width dash -> single full-width dash
        .gsub(/[\uff5e]/, "\u301c")  # full-width tilde -> full-width wave dash
        .gsub(/[\u2012\u2013\u2015\u2212\uff0d]/, "\u2014")  # hyphen and dashes 
        .strip
  end
end
