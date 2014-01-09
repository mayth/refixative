class CreateMusics < ActiveRecord::Migration
  def change
    create_table :musics do |t|
      t.string :name, index: true
      t.references :version, index: true
      t.integer :basic_lv
      t.integer :medium_lv
      t.integer :hard_lv
      t.date :added_at
      t.date :deleted_at

      t.timestamps
    end
  end
end
