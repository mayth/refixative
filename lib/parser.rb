require 'time'
require 'cgi/util'
require 'nokogiri'

module Parser
  module Colette
    DIFFICULTY = [:basic, :medium, :hard]

    module_function
    # html: String, or File
    def parse_profile(html)
      doc = Nokogiri::HTML(html) {|config| config.nonet }
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

    def parse_music(html)
      doc = Nokogiri::HTML(html) {|config| config.nonet }
      musics = Array.new
      doc.css('#music_table1 tbody tr').each do |row|
        next unless row.css('th').empty?
        scores = Hash.new
        (1..3).each do |i|
          col = row.css('td')[i]
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
          end
          scores[DIFFICULTY[i - 1]] = {
            lv: col.at_css('.lv').text.strip.to_i,
            achieve: achieve,
            miss: miss
          }
        end
        musics << {
          name: Parser.name_normalize(row.at_css('img').attr('alt')),
          scores: scores
        }
      end
      musics 
    end
  end # end module

  module_function
  def name_normalize(name)
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
  prof = nil
  open(ARGV[0], 'r:shift_jis') do |f|
    prof = ::Parser::Colette.parse_profile(f)
  end
  song = nil
  open(ARGV[1], 'r:shift_jis') do |f|
    song = ::Parser::Colette.parse_music(f)
  end
  p prof
  p song
end
