class Version < ActiveRecord::Base
  has_many :musics
  validates_presence_of :name
  validates_presence_of :released_at
end
