class Player < ActiveRecord::Base
  has_many :scores, inverse_of: :player, dependent: :destroy
  belongs_to :team, inverse_of: :players

  structure do
    pid 'RB-1234-5678',
      validates: [
        :presence,
        :uniqueness,
        format: { with: /\ARB-\d{4}-\d{4}\z/ }
      ]
    name 'ＰＬＡＹＥＲ', validates: :presence
    pseudonym '期待の新鋭', validates: :presence
    level 2, validates: [
      :presence,
      numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    ]
    grade '師範代'
    comment '小傘ちゃんかわいい'
    play_count 1, validates: [
      :presence,
      numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    ]
    refle 1550, validates: [
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
    updates = {}
    new_plays = []
    scores.each do |score|
      music = Music.find_by(name: score[:name])
      next unless music
      Difficulty::DIFFICULTIES.each do |difficulty|
        next if score[:scores][difficulty].nil? || score[:scores][difficulty][:achievement].nil?
        old_score = latest_score(music, difficulty)
        current_score = score[:scores][difficulty]
        check_update(
          music, difficulty,
          current_score, old_score,
          updates, new_plays)
      end
    end
    [updates, new_plays]
  end

  def update_score(musics, updated_at = Time.now)
    Score.record_timestamps = false
    retval = musics.each_with_object([]) do |music_hash, updated_score|
      music = Music.find_by(name: music_hash[:name])
      next unless music
      music_hash[:scores].each do |difficulty, new_score|
        next unless new_score[:achievement]
        current_score = latest_score(music, difficulty)
        updated_score << create_updated_score(
          music, difficulty, current_score, new_score, updated_at)
      end
    end
    retval.compact
  ensure
    Score.record_timestamps = true
  end

  def latest_score(music, difficulty = nil)
    if difficulty
      scores
        .order(created_at: :desc)
        .find_by(music: music, difficulty: difficulty.to_i)
    else
      Difficulty::DIFFICULTIES.map { |d| [d, latest_score(music, d)] }.to_h
    end
  end

  def latest_scores(compaction = false)
    Music.all.each_with_object({}) do |music, result|
      current_scores = latest_score(music)
      current_scores.reject! {|difficulty, score| score.nil? } if compaction
      result[music] = current_scores
    end
  end

  def self.update_profile(profile, updated_at = nil)
    Player.record_timestamps = false if updated_at.present?
    pl = Player.find_or_create_by(pid: profile[:id]) do |player|
      player.name = profile[:name]
      player.pseudonym = profile[:pseudonym]
      player.level = profile[:level]
      player.grade = profile[:grade]
      player.comment = profile[:comment]
      player.play_count = profile[:play_count]
      player.refle = profile[:refle]
      player.total_point = profile[:total_point]
      player.last_play_place = profile[:last_play_place]
      player.last_play_datetime = profile[:last_play_datetime]
      player.created_at ||= updated_at
      player.updated_at = updated_at if updated_at.present?
    end
    pl
  ensure
    Player.record_timestamps = true if updated_at.present?
  end

  private

  def create_updated_score(music, difficulty, current_score, new_score, updated_at)
    return nil if
      current_score.present? && !score_updated?(current_score, new_score)
    achievement = [current_score.try(:achievement) || -Float::INFINITY, new_score[:achievement]].max
    miss_count = [current_score.try(:miss_count) || Float::INFINITY, new_score[:miss_count]].min
    scores.create(music: music, difficulty: difficulty,
                  achievement: achievement, miss_count: miss_count,
                  updated_at: updated_at, created_at: updated_at)
  end

  def check_update(music, difficulty, current_score, old_score, updates, new_plays)
    if old_score
      if old_score.achievement < current_score[:achievement]
        current_score[:is_achievement_updated] = :true
        updates[old_score] = current_score
      end
      if current_score[:miss_count] < old_score.miss_count
        current_score[:is_miss_count_updated] = :true
        updates[old_score] = current_score
      end
    else
      current_score[:is_achievement_updated] = :new_play
      current_score[:is_miss_count_updated] = :new_play
      new_plays << { music: music, difficulty: difficulty, score: current_score }
    end
  end

  def score_updated?(current_score, new_score)
    current_score.achievement < new_score[:achievement] ||
      current_score.miss_count > new_score[:miss_count]
  end
end
