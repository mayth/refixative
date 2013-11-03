class Player < ActiveRecord::Base
  belongs_to :team
  has_many :scoresets
  validates_presence_of :name
  validates_presence_of :pseudonym
  validates_presence_of :play_count
  validates_presence_of :stamp
  validates_presence_of :onigiri
  validates_presence_of :last_play_date
  validates_presence_of :last_play_shop
end
