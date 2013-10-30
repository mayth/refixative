class CreateVersions < ActiveRecord::Migration
  def self.up
    create_table :versions do |t|
      t.primary_key :id
      t.string :name, null: false
      t.datetime :released_at, null: false
      t.timestamps
    end
  end

  def self.down
    drop_table :versions
  end
end
