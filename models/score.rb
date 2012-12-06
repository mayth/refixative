class Score < Sequel::Model
  one_to_one :scoreset
  many_to_one :music
end
