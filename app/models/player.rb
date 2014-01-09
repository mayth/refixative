class Player < ActiveRecord::Base
  self.primary_key = :id
  has_many :scores
  belongs_to :team
end
