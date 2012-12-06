Sequel.migration do
  change do
    create_table :scores do
      primary_key :id
      foreign_key :music_id, :musics
      Integer :difficulty, :null => false
      Float :achieve
      Integer :miss
    end
  end
end
