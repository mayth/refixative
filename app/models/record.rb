class Record < ActiveRecord::Base
  belongs_to :score, inverse_of: :records
  structure do
    achieve    90.0, validates: [:presence, :numericality]
    miss       3, validates: [
      :presence,
      numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    ]
    timestamps
  end
  validates_associated :score
  validates :score, presence: true
end

