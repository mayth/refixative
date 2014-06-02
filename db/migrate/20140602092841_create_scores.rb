class CreateScores < ActiveRecord::Migration
  def self.up
    create_table :scores do |t|
      t.integer :player_id 
      t.integer :music_id 
      t.integer :difficulty 
      t.datetime :updated_at 
      t.datetime :created_at 
    end
    add_index :scores, :player_id
    add_index :scores, :music_id
  end
  
  def self.down
    drop_table :scores
  end
end
