class CreateMusics < ActiveRecord::Migration
  def self.up
    create_table :musics do |t|
      t.integer :version_id 
      t.string :name 
      t.integer :basic_lv 
      t.integer :medium_lv 
      t.integer :hard_lv 
      t.integer :special_lv 
      t.datetime :added_at 
      t.datetime :updated_at 
      t.datetime :created_at 
    end
    add_index :musics, :version_id
    add_index :musics, :name
  end
  
  def self.down
    drop_table :musics
  end
end
