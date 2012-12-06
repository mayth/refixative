class Music < Sequel::Model
  one_to_one :score
  many_to_one :version
end
