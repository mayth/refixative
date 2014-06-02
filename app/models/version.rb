class Version < ActiveRecord::Base
  has_many :musics, inverse_of: :version
  structure do
    name        "colette Winter"
    released_at Time.new(2012, 11, 21, 10, 0, 0, '+09:00')
    timestamps
  end
end

