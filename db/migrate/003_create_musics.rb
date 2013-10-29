class CreateMusics < ActiveRecord::Migration
  def self.up
    create_table :musics do |t|
      t.primarykey :id
      t.string :name
      t.references :version
      t.integer :basic_lv
      t.integer :medium_lv
      t.integer :hard_lv
      t.date :added_at
      t.timestamps
    end
  end

  def self.down
    drop_table :musics
  end
end
