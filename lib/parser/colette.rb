require 'time'
require 'cgi/util'
require 'nokogiri'

module Parser
  class Colette
    # html: String, or File
    def parse_profile(html)
      _parse_profile(Nokogiri::HTML(html) {|config| config.nonet })
    end

    def parse_song(html)
      _parse_song(Nokogiri::HTML(html) {|config| config.nonet })
    end

    private

    def _parse_profile(doc)
      player = {
        id: doc.at_css('#plofbox dl dd').text.strip,
        pseudonym: doc.at_css('#plofbox2').text.strip.gsub(/^(\S+)(.*)/, '\1'),
        name: doc.at_css('#plofbox2 .plofbox2').text.strip,
        comment: doc.at_css('#right_con_plf2 dl dd').text.strip,
        stamp: doc.css('#profileL_box div')[1].at_css('dl dd').text.strip.to_i,
        play_count: doc.css('#profileL_box div')[2].at_css('dl dd').text.strip.to_i,
        last_play_shop: doc.css('#profileL_box div')[3].at_css('dl dd').text.strip,
        onigiri: doc.css('#profileR_box div')[1].at_css('dl dd').text.strip.to_i,
        last_play_date: Time.parse(doc.css('#profileR_box div')[3].at_css('dl dd').text.strip)
      }
      team = {
        name: doc.css('#profileL_box div')[0].at_css('dl dd').text.strip,
        id: doc.css('#profileR_box div')[0].at_css('dl dd').text.strip
      }
      unless team[:id] == '未設定'
        team[:id] = team[:id].to_i
        player[:team] = team
      end
      player
    end

    def _parse_song(doc)
      songs = []
      doc.css('#music_table1 tbody tr').each do |row|
        next unless row.css('th').empty?
        scores = get_scores(row)
        songs << {
          name: Parser.name_normalize(row.at_css('img').attr('alt')),
          scores: scores
        }
      end
      songs
    end

    def get_scores(row)
      x = (0..2).map do |i|
        col = row.css('td')[i + 1]
        if col.children.first.text.strip == '-'
          achieve = nil
        else
          values_node = col.css('div')
          achieve = values_node.at_css('.fcph').text.strip.to_f
          if values_node.at_css('.fch').matches?('img')
            miss = 0
          else
            miss = values_node.at_css('.fch').text.strip.to_i
          end
          rating = 
            case achieve
            when 0...50  then 0 # C
            when 50...70 then 1 # B
            when 70...80 then 2 # A
            when 80...90 then 3 # AA
            when 90...95 then 4 # AAA
            else              5 # AAA+
            end
        end
        [
          Difficulty.from_int(i), {
            lv: col.at_css('.lv').text.strip.to_i,
            achieve: achieve,
            miss: miss,
            rating: rating
          }
        ]
      end
      x.to_h
    end
  end # end class

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
end # end module

if __FILE__ == $0
  parser = Parser::Colette.new
  prof = nil
  open(ARGV[0], 'r:shift_jis') do |f|
    prof = parser.parse_profile(f)
  end
  song = nil
  open(ARGV[1], 'r:shift_jis') do |f|
    song = parser.parse_song(f)
  end
  p prof
  p song
end