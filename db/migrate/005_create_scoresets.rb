class CreateScoresets < ActiveRecord::Migration
  def self.up
    create_table :scoresets do |t|
      t.primary_key :id
      t.references :player, null: false
      t.datetime :registered_at, null: false
      t.timestamps
    end
  end

  def self.down
    drop_table :scoresets
  end
end
