class Music < ActiveRecord::Base
  belongs_to :version

  validates :name, presence: true
  validates :basic_lv, :medium_lv, :hard_lv,
    numericality: true, inclusion: { in: 1..10 }
  validates :added_at, presence: true
end
