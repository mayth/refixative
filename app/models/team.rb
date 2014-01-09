class Team < ActiveRecord::Base
  self.primary_key = :id
  has_many :players
end
