class Score < ActiveRecord::Base
  belongs_to :player, inverse_of: :scores
  belongs_to :music, inverse_of: :scores
  has_many :records, inverse_of: :score, dependent: :destroy
  structure do
    difficulty Difficulty::MEDIUM, validates: :presence
    timestamps
  end

  validates_associated :player
  validates :player, presence: true
  validates_associated :music
  validates :music, presence: true

  def difficulty
    @difficulty ||= Difficulty.from_int(self[:difficulty])
  end

  def difficulty=(val)
    case val
    when String
      @difficulty = Difficulty.new(val)
    when Integer
      @difficulty = Difficulty.from_int(val)
    when Difficulty
      @difficulty = val
    else
      fail TypeError, 'unexpected value for difficulty'
    end
    self[:difficulty] = @difficulty.to_i
  end
end

