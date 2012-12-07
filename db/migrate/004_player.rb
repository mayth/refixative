Sequel.migration do
  change do
    create_table :players do
      Integer :id, :primary_key => true
      String :name, :null => false, :size => 8
      String :pseudonym, :null => false
      String :comment, :null => false, :size => 16
      foreign_key :team_id, :teams
      Integer :play_count, :null => false
      Integer :stamp, :null => false
      Integer :onigiri, :null => false
      DateTime :last_play_date, :null => false
      String :last_play_shop, :null => false
      Integer :latest_scoreset_id, :null => false
    end
  end
end
