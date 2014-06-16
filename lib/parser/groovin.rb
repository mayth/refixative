require 'parser/parser'
require 'time'
require 'cgi/util'
require 'nokogiri'

class GroovinParser < Refixative::Parser
  private

  def _parse_profile(doc)
    player = {
      id: doc.at_css('#userid').text.strip,
      pseudonym: doc.at_css('#plofbox2 span').text.strip.gsub(/^(\S+)(.*)/, '\1'),
      name: doc.at_css('#plofbox2 p').text.strip,
      comment: doc.at_css('#comment dd').text.strip,
      play_count: doc.css('#profile_listcont div')[0].at_css('dl dd span').text.strip.to_i,
      grade: doc.css('#profile_listcont div')[1].at_css('dl dd span').text.strip,
      level: doc.css('#profile_listcont div')[2].at_css('dl dd span').text.strip.to_i,
      refle: doc.css('#profile_listcont div')[3].at_css('dl dd span').text.strip.to_i,
      total_point: doc.css('#profile_listcont div')[4].at_css('dl dd span').text.strip.to_i,
      last_play_place: doc.css('#profile_listcont div')[6].at_css('dl dd span').text.strip,
      last_play_datetime: doc.css('#profile_listcont div')[7].at_css('dl dd span').text.strip,
      team: nil
    }
    player[:grade] = nil if player[:grade] == '-'
    #team = {
    #  name: doc.css('#profileL_box div')[0].at_css('dl dd').text.strip,
    #  id: doc.css('#profileR_box div')[0].at_css('dl dd').text.strip
    #}
    #unless team[:id] == '未設定'
    #  team[:id] = team[:id].to_i
    #  player[:team] = team
    #end
    player
  end

  def _parse_music(doc)
    musics = []
    doc.css('#music_table1 tbody td').each_slice(5) do |cols|
      scores = get_scores(cols)
      musics << {
        name: name_normalize(cols[0].at_css('a').text),
        scores: scores
      }
    end
    musics
  end

  def get_scores(cols)
    x = (1..4).map do |i|
      col = cols[i]
      unless col.text.strip == '-'
        values_node = col.css('div')
        achieve = values_node.at_css('.fcph').text.strip.to_f
        miss =
          if values_node.at_css('.fch').matches?('img')
            0
          else
            values_node.at_css('.fch').text.strip.to_i
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
          achievement: achieve,
          miss_count: miss,
          rating: rating
        }
      ]
    end
    x.to_h
  end
end # end class

# rubocop:disable Output
if __FILE__ == $PROGRAM_NAME
  parser = GroovinParser.new
  prof = nil
  warn 'processing profile page'
  open(ARGV.shift, 'r:shift_jis') do |f|
    prof = parser.parse_profile(f)
  end
  musics = []
  page = 1
  while music_file = ARGV.shift
    warn "processing music page #{page}"
    open(music_file, 'r:shift_jis') do |f|
      musics += parser.parse_music(f)
    end
    page += 1
  end
  p prof
  p musics
end
