class CreateRecords < ActiveRecord::Migration
  def change
    create_table :records do |t|
      t.references :score, index: true
      t.float :achievement
      t.integer :miss_count

      t.timestamps
    end
  end
end
