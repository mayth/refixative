class ChangedScoresAddedAchievementMissCount < ActiveRecord::Migration
  def self.up
    add_column :scores, :achievement, :float
    add_column :scores, :miss_count, :integer
  end
  
  def self.down
    remove_column :scores, :achievement
    remove_column :scores, :miss_count
  end
end
