class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams, id: false, primary_key: :id do |t|
      t.integer :id, limit: 6
      t.string :name, index: true

      t.timestamps
    end
    add_index :teams, :id, unique: true
  end
end
