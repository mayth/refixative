class Music < ActiveRecord::Base
  belongs_to :score
  belongs_to :version
  validates_presence_of :name
  validates_presence_of :basic_lv
  validates_presence_of :medium_lv
  validates_presence_of :hard_lv
  validates_presence_of :added_at
end
