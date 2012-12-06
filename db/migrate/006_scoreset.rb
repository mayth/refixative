Sequel.migration do
  change do
    create_table :scoresets do
      Integer :id
      foreign_key :player_id, :players, :deferrable => true
      foreign_key :score_id, :scores
      DateTime :updated_at, :null => false

      index :id
    end
  end
end
