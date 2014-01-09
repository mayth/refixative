class CreateVersions < ActiveRecord::Migration
  def change
    create_table :versions do |t|
      t.string :name, index: true
      t.date :released_at

      t.timestamps
    end
  end
end
