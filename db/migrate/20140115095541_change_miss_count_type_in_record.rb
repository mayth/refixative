class ChangeMissCountTypeInRecord < ActiveRecord::Migration
  def change
    change_column :records, :miss_count, :float
  end
end
