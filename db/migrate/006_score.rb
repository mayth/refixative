Sequel.migration do
  change do
    create_table :scores do
      primary_key :id
      foreign_key :music_id, :musics
      foreign_key :scoreset_id, :scoresets
      Integer :difficulty, :null => false
      Float :achieve
      Integer :miss
    end
  end
end
