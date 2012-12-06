class Scoreset < Sequel::Model
  many_to_one :player
  many_to_one :score
end
