class Player < Sequel::Model
  unrestrict_primary_key
  one_to_one :scoreset
  many_to_one :team
end
