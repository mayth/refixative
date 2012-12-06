class Player < Sequel::Model
  one_to_one :scoreset
  many_to_one :team
end
