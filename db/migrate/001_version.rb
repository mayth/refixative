Sequel.migration do
  change do
    create_table :versions do
      primary_key :id
      String :name, :null => false
      DateTime :released_at, :null => false
    end
  end
end
