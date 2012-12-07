class Team < Sequel::Model
  unrestrict_primary_key
  one_to_one :player
end
