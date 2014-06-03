class Team < ActiveRecord::Base
  has_many :players, inverse_of: :team, dependent: :nullify
  structure do
    name        'ウィザウチュナイ', validates: :presence
    timestamps
  end
end

