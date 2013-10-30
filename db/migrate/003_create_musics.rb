class CreateMusics < ActiveRecord::Migration
  def self.up
    create_table :musics do |t|
      t.primary_key :id
      t.string :name, null: false
      t.references :version, null: false
      t.integer :basic_lv, null: false
      t.integer :medium_lv, null: false
      t.integer :hard_lv, null: false
      t.date :added_at, null: false
      t.timestamps
    end
  end

  def self.down
    drop_table :musics
  end
end
