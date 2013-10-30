class CreateScores < ActiveRecord::Migration
  def self.up
    create_table :scores do |t|
      t.primary_key :id
      t.references :music, null: false
      t.references :scoreset, null: false
      t.integer :difficulty, null: false
      t.float :achieve, null: false
      t.integer :miss, null: false
      t.timestamps
    end
  end

  def self.down
    drop_table :scores
  end
end
