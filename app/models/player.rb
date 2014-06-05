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
