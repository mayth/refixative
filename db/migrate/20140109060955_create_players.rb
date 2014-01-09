class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players, id: false, primary_key: :id do |t|
      t.integer :id, null: false, limit: 6
      t.string :name, index: true
      t.string :pseudonym
      t.string :comment
      t.references :team, index: true
      t.integer :play_count
      t.integer :stamp
      t.integer :onigiri
      t.datetime :last_play_date
      t.string :last_play_shop

      t.timestamps
    end
    add_index :players, :id, unique: true
  end
end
