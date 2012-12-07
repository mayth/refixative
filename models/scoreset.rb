class Scoreset < Sequel::Model
  many_to_one :player
  one_to_many :score
end
