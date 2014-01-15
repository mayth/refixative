class Team < ActiveRecord::Base
  self.primary_key = :id
  has_many :players

  validates :id,
    presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :name, presence: true, length: { maximum: 8 }
end
