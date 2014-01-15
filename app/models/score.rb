class Score < ActiveRecord::Base
  has_many :records
  belongs_to :player
  belongs_to :music

  validates_associated :player
  validates_associated :music
  validates :difficulty, presence: true, inclusion: { in: 0..2 }
end
