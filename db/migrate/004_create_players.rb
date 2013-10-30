class CreatePlayers < ActiveRecord::Migration
  def self.up
    create_table :players do |t|
      t.primary_key :id
      t.string :name, limit: 8, null: false
      t.string :pseudonym, null: false
      t.string :comment, limit: 16, null: false
      t.references :team
      t.integer :play_count, null: false
      t.integer :stamp, null: false
      t.integer :onigiri, null: false
      t.datetime :last_play_date, null: false
      t.string :last_play_shop, null: false
      t.timestamps
    end
  end

  def self.down
    drop_table :players
  end
end
