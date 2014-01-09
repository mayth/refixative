class CreateScores < ActiveRecord::Migration
  def change
    create_table :scores do |t|
      t.references :player, index: true
      t.references :music, index: true
      t.integer :difficulty
      t.references :latest_record, index: true

      t.timestamps
    end
  end
end
