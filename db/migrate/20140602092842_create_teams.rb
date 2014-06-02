class CreateTeams < ActiveRecord::Migration
  def self.up
    create_table :teams do |t|
      t.string :name 
      t.datetime :updated_at 
      t.datetime :created_at 
    end
    add_index :teams, :name
  end
  
  def self.down
    drop_table :teams
  end
end
