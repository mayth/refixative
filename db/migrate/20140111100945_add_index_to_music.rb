class AddIndexToMusic < ActiveRecord::Migration
  def change
    add_column :musics, :index, :string
  end
end
