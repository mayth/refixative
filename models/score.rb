class Score < Sequel::Model
  many_to_one :scoreset
  many_to_one :music
end
