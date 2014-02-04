Sequel.migration do

  change do
    create_table(:zusers) do
      primary_key :id

      String    :nick,  null: false
      String    :user
      String    :real
      String    :host
      String    :role,  default: 'nobody'
      Boolean   :ircop, default: false

      index [:nick, :role, :ircop], unique: true
    end
  end

end