class Version < ActiveRecord::Base
  has_many :musics

  validates :name, presence: true
  validates :released_at, presence: true
end
