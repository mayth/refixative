class CreateVersions < ActiveRecord::Migration
  def self.up
    create_table :versions do |t|
      t.primarykey :id
      t.string :name
      t.datetime :released_at
      t.timestamps
    end
  end

  def self.down
    drop_table :versions
  end
end
