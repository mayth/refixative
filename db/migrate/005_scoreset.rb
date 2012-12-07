Sequel.migration do
  change do
    create_table :scoresets do
      primary_key :id
      foreign_key :player_id, :players
      DateTime :registered_at, :null => false
    end
  end
end
