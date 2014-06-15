class Version < ActiveRecord::Base
  has_many :musics, inverse_of: :version
  structure do
    name "colette Winter", validates: :presence
    released_at Time.new(2012, 11, 21, 10, 0, 0, '+09:00'), validates: :presence
    timestamps
  end
end

