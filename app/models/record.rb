class Record < ActiveRecord::Base
  belongs_to :score

  validates_associated :score
  validates :achievement, numericality: true
  validates :miss_count, numericality: true
end
