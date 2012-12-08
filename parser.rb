#coding: utf-8
require 'time'
require 'cgi/util'
require 'nokogiri'

module Parser
  class Colette
    DIFFICULTY = [:basic, :medium, :hard]

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
      p team
      unless team[:id] == '未設定'
        team[:id] = team[:id].to_i
        player[:team] = team
      end
      player
    end

    def _parse_song(doc)
      songs = Array.new
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
            if achieve < 50.0
              rating = 0  # C
            elsif achieve < 70.0
              rating = 1  # B
            elsif achieve < 80.0
              rating = 2  # A
            elsif achieve < 90.0
              rating = 3  # AA
            elsif achieve < 95.0
              rating = 4  # AAA
            else
              rating = 5  # AAA+
            end
          end
          scores[DIFFICULTY[i - 1]] = {
            lv: row.css('td')[i].at_css('.lv').text.strip.to_i,
            achieve: achieve,
            miss: miss,
            rating: rating
          }
        end
        songs << {
          id: CGI.unescape(row.children[0].at_css('img').attr('src').gsub(/(.+?)img=(.+)$/, '\2')),
          name: row.children[0].at_css('img').attr('alt'),
          scores: scores
        }
      end
      songs
    end
  end # end class
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
