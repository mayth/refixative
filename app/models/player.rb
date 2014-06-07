class Player < ActiveRecord::Base
  has_many :scores, inverse_of: :player, dependent: :destroy
  belongs_to :team, inverse_of: :players

  structure do
    pid     'RB-1234-5678',
      validates: [
        :presence,
        :uniqueness,
        format: { with: /\ARB-\d{4}-\d{4}\z/ }
      ]
    name    'ＰＬＡＹＥＲ', validates: :presence
    pseudonym '期待の新鋭', validates: :presence
    level     2, validates: [
        :presence,
        numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      ]
    grade      '師範代'
    comment    '小傘ちゃんかわいい'
    play_count  1, validates: [
        :presence,
        numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      ]
    refle       1550, validates: [
        :presence,
        numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      ]
    total_point 6670, validates: [
        :presence,
        numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      ]
    last_play_datetime Time.now
    last_play_place 'ジャムジャムつくば店'

    timestamps
  end

  validates_associated :team

  # `scores' should be
  # [
  #   {
  #     name: 'music name',
  #     scores: {
  #       BASIC:  { achievement: 90.0, miss: 3,   rating: 'AAA' },
  #       MEDIUM: { achievement: nil,  miss: nil, rating: nil },
  #       ...
  #     }
  #   },
  #   { another music data }, ...
  # ]
  def check_updates(scores)
    scores.each do |score|
      music = Music.find_by(name: score[:name])
      next unless music
      Difficulty::DIFFICULTIES.each do |difficulty|
        next if score[:scores][difficulty].nil? || score[:scores][difficulty][:achievement].nil?
        old_score = latest_score(music, difficulty)
        current_score = score[:scores][difficulty]
        if old_score
          current_score[:is_achievement_updated] =
            (old_score.achievement < current_score[:achievement]).to_s.to_sym
          current_score[:is_miss_count_updated] =
            (current_score[:miss_count] < old_score.miss_count).to_s.to_sym
        else
          current_score[:is_achievement_updated] = :new_play
          current_score[:is_miss_count_updated] = :new_play
        end
      end
    end
  end

  def update_score(musics)
    musics.each_with_object([]) do |music_hash, updated_score|
      music = Music.find_by(name: music_hash[:name])
      next unless music
      music_hash[:scores].each do |difficulty, new_score|
        next unless new_score[:achievement]
        current_score = latest_score(music, difficulty)
        p new_score
        if current_score
          if current_score.achievement < new_score[:achievement] || 
             current_score.miss_count > new_score[:miss_count]
            updated_score << scores.create(
              music: music,
              difficulty: difficulty,
              achievement: [current_score.achievement, new_score[:achievement]].max,
              miss_count: [current_score.miss_count, new_score[:miss_count]].min
            )
          end
        else
          updated_score << scores.create(
            music: music,
            difficulty: difficulty,
            achievement: new_score[:achievement],
            miss_count: new_score[:miss_count]
          )
        end
      end
    end
  end

  def latest_score(music, difficulty = nil)
    if difficulty
      scores
        .order(created_at: :desc)
        .find_by(music: music, difficulty: difficulty.to_i)
    else
      Difficulty::DIFFICULTIES.map {|d|
        [d, latest_score(music, d)]
      }.to_h
    end
  end

  def latest_scores(compaction = false)
    Music.all.each_with_object({}) do |music, result|
      current_scores = latest_score(music)
      if compaction
        current_scores.reject! {|difficulty, score| score.nil? }
      end
      result[music] = current_scores
    end
  end

  def self.update_profile(profile)
    Player.first_or_create(pid: profile[:pid]) do |player|
      player.pid = profile[:id]
      player.name = profile[:name]
      player.pseudonym = profile[:pseudonym]
      player.level = profile[:level]
      player.grade = profile[:grade]
      player.comment = profile[:comment]
      player.play_count = profile[:play_count]
      player.refle = profile[:refle]
      player.total_point = profile[:total_point]
      player.last_play_place = profile[:last_play_place]
      player.last_play_datetime = profile[:last_play_date]
    end
  end
end
