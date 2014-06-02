class CreateRecords < ActiveRecord::Migration
  def self.up
    create_table :records do |t|
      t.integer :score_id 
      t.float :achieve 
      t.integer :miss 
      t.datetime :updated_at 
      t.datetime :created_at 
    end
    add_index :records, :score_id
  end
  
  def self.down
    drop_table :records
  end
end
