class Score < ActiveRecord::Base
  belongs_to :player, inverse_of: :scores
  belongs_to :music, inverse_of: :scores
  structure do
    difficulty :integer, Difficulty::MEDIUM, validates: :presence
    achievement 90.0, validates: [:presence, :numericality]
    miss_count 3, validates: [
      :presence, numericality: { only_integer: true, greater_than_or_equal_to: 0 }]
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
    @difficulty =
      case val
      when Difficulty
        val
      when String
        Difficulty.new(val)
      when Integer
        Difficulty.from_int(val)
      else
        if val.respond_to?(:to_s)
          Difficulty.new(val.to_s)
        elsif val.respond_to?(:to_i)
          Difficulty.from_int(val.to_i)
        else
          fail ArgumentError, 'cannot convert the given value to a difficulty'
        end
      end
    self[:difficulty] = @difficulty.to_i
    @difficulty
  end
end
