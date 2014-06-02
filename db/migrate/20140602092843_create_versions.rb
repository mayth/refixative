class CreateVersions < ActiveRecord::Migration
  def self.up
    create_table :versions do |t|
      t.string :name 
      t.datetime :released_at 
      t.datetime :updated_at 
      t.datetime :created_at 
    end
    add_index :versions, :name
  end
  
  def self.down
    drop_table :versions
  end
end
