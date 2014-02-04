Sequel.migration do
  change do
    alter_table(:zusers) do
      add_column :authname, String, default:false
    end
  end
end