class Score < ActiveRecord::Base
  has_many :records
  belongs_to :player
  belongs_to :music
end
