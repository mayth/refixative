class CreatePlayers < ActiveRecord::Migration
  def self.up
    create_table :players do |t|
      t.integer :team_id 
      t.string :pid 
      t.string :name 
      t.datetime :last_play_datetime 
      t.string :last_play_place 
      t.datetime :updated_at 
      t.datetime :created_at 
    end
    add_index :players, :team_id
    add_index :players, :pid, unique: true
  end
  
  def self.down
    drop_table :players
  end
end
