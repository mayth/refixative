require 'logger'
require 'haml'
require 'json'
load './db_setup.rb'

Dir.glob('./models/*.rb').each do |s|
  require_relative s
end

DIFFICULTY = [:basic, :medium, :hard]

logger = Logger.new(STDOUT)

scores = Hash.new
score_average = Hash.new
Music.all.each do |m|
  scores[m.name] = {
    basic: {
      achieve: 0.0,
      miss: 0,
      count: 0
    },
    medium: {
      achieve: 0.0,
      miss: 0,
      count: 0
    },
    hard: {
      achieve: 0.0,
      miss: 0,
      count: 0
    }
  }
  score_average[m.name] = {
    basic: {
      achieve: 0.0,
      miss: 0,
      count: 0
    },
    medium: {
      achieve: 0.0,
      miss: 0,
      count: 0
    },
    hard: {
      achieve: 0.0,
      miss: 0,
      count: 0
    }
  }
end
player_sum = {
  play_count: 0,
  stamp: 0,
  onigiri: 0
}

players = Player.all
players.each do |player|
  player_sum[:play_count] += player[:play_count]
  player_sum[:stamp] += player[:stamp]
  player_sum[:onigiri] += player[:onigiri]
  # score sum
  scoreset = Scoreset[id: player[:latest_scoreset_id]]
  unless scoreset
    logger.warn "Cannot find scoreset:#{player[:latest_scoreset_id]} (player:#{player[:id]}"
    next
  end
  scoreset.score.each do |score|
    s = scores[score.music.name][DIFFICULTY[score.difficulty]]
    s[:achieve] += score.achieve
    s[:miss] += score.miss
    s[:count] += 1
  end
end

player_num = players.size
player_average = {
  play_count: player_sum[:play_count] / player_num,
  stamp: player_sum[:stamp] / player_num,
  onigiri: player_sum[:onigiri] / player_num
}

scores.each do |name, score|
  score.each do |difficulty, v|
    if v[:count] != 0
      achieve = v[:achieve] / v[:count]
      if achieve < 50.0
        rank = 'C'
      elsif achieve < 70.0
        rank = 'B'
      elsif achieve < 80.0
        rank = 'A'
      elsif achieve < 90.0
        rank = 'AA'
      elsif achieve < 95.0
        rank = 'AAA'
      else
        rank = 'AAA+'
      end
      score_average[name][difficulty] = 
       { achieve: v[:achieve] / v[:count], miss: v[:miss].to_f / v[:count], rank: rank, count: v[:count]}
    else
      score_average[name][difficulty] = { achieve: 0.0, miss: 0, count: 0 }
    end
  end
end

IO.write('average.dat', JSON.generate({ score_average: score_average, player_average: player_average, player_num: player_num, updated_at: Time.now }))
