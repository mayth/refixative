Sequel.migration do
  change do
    alter_table :musics do
      add_column :hash_id, String, null: false, fixed: true, size: 44
    end
  end
end
