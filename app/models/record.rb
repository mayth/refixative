class Record < ActiveRecord::Base
  belongs_to :score, inverse_of: :records
  structure do
    achieve    90.0
    miss       3
    timestamps
  end
end

