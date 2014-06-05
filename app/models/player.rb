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
  #       BASIC:  { achieve: 90.0, miss: 3,   rating: 'AAA' },
  #       MEDIUM: { achieve: nil,  miss: nil, rating: nil },
  #       ...
  #     }
  #   },
  #   { another music data }, ...
  # ]
  def check_updates(scores)
    old_scores = latest_scores
    if old_scores
      scores.each do |score|
        Difficulty::AVAILABLE.each do |difficulty|
          next unless score[:scores][difficulty][:achieve]
          current_score = score[:scores][difficulty]
          old_score = old_scores.find { |old| old.music.name == score[:name] }
          if old_score
            current_score[:is_achieve_updated] =
              (old_score.achieve < current_score.achieve).to_s.to_sym
            current_score[:is_miss_count_updated] =
              (current_score[:miss] < old_score.miss).to_s.to_sym
          else
            current_score[:is_achieve_updated] = :new_play
            current_score[:is_miss_count_updated] = :new_play
          end
        end
      end
    end
  end

  def latest_scores
    scores.map(&:latest)
  end
end
