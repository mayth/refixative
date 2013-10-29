class CreateScores < ActiveRecord::Migration
  def self.up
    create_table :scores do |t|
      t.primarykey :id
      t.references :music
      t.references :scoreset
      t.integer :difficulty
      t.float :achieve
      t.integer :miss
      t.timestamps
    end
  end

  def self.down
    drop_table :scores
  end
end
