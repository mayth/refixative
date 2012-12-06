class Team < Sequel::Model
  one_to_one :player
end
