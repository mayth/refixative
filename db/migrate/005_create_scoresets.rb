class CreateScoresets < ActiveRecord::Migration
  def self.up
    create_table :scoresets do |t|
      t.primarykey :id
      t.references :player
      t.datetime :registered_at
      t.timestamps
    end
  end

  def self.down
    drop_table :scoresets
  end
end
