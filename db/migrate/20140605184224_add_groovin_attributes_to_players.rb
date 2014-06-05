class AddGroovinAttributesToPlayers < ActiveRecord::Migration
  def self.up
    add_column :players, :grade, :string
    add_column :players, :comment, :string
    add_column :players, :level, :integer
    add_column :players, :play_count, :integer
    add_column :players, :pseudonym, :string
    add_column :players, :refle, :integer
    add_column :players, :total_point, :integer
  end
  
  def self.down
    remove_column :players, :grade
    remove_column :players, :comment
    remove_column :players, :level
    remove_column :players, :play_count
    remove_column :players, :pseudonym
    remove_column :players, :refle
    remove_column :players, :total_point
  end
end
