Sequel.migration do
  up do
    create_table(:users) do
      primary_key :id
      String :nickname, null: false
      String :username, null: true
      String :hostname, null: true
      String :authname, null: true

      # Security
      String :access,     default: 1
      Bool :ignore,       default: false
      Bool :auto_voice,   default: false
      Bool :auto_op,      default: false
      Bool :auto_halfop,  default: false

      # Location
      String :location, null: true

      # Stats
      Integer :plugin_usage, default: 0
    end
  end

  down do
    drop_table(:users)
  end
end