class Scoreset < ActiveRecord::Base
  belongs_to :player
  has_many :scores
end
