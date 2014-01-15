class Player < ActiveRecord::Base
  self.primary_key = :id
  has_many :scores
  belongs_to :team

  validates :id,
    presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :name, presence: true, length: { maximum: 8 }
  validates :pseudonym, presence: true
  validates :comment, length: { maximum: 16 }
  validates :play_count, :stamp, :onigiri,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :last_play_date, presence: true
  validates :last_play_shop, presence: true
end
