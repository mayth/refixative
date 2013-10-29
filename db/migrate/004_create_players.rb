class CreatePlayers < ActiveRecord::Migration
  def self.up
    create_table :players do |t|
      t.primarykey :id
      t.string{8} :name
      t.string :pseudonym
      t.string{16} :comment
      t.references :team
      t.integer :play_count
      t.integer :stamp
      t.integer :onigiri
      t.datetime :last_play_date
      t.string :last_play_shop
      t.timestamps
    end
  end

  def self.down
    drop_table :players
  end
end
