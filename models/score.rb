class Score < ActiveRecord::Base
  belongs_to :scoreset
  has_one :music
end
