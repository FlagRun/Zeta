Sequel.migration do
  up do
    create_table(:channels) do
      primary_key :id
      String :name, default: false

      # do not respond to channel
      Bool :disabled, default: false

      # Auto modes
      Bool :auto_voice, default: false

      # Ignore
      String :ignore_plugins, null: true
      String :ignore_users, null: true
    end
  end

  down do
    drop_table(:channels)
  end
end