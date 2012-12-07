Sequel.migration do
  change do
    create_table :musics do
      primary_key :id
      String :name, :null => false
      Integer :version_id, :null => false
      Integer :basic_lv, :null => false
      Integer :medium_lv, :null => false
      Integer :hard_lv, :null => false
      Date :added_at
    end
  end
end
