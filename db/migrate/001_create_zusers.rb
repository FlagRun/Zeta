class CreateZusers < ActiveRecord::Migration
  def self.up
    create_table :zusers do |t|
      t.column :nick, :string, null: false
      t.column :user, :string
      t.column :real, :string
      t.column :host, :string
      t.column :auth, :string
      t.column :role, :string, default: 'nobody'
      t.column :auth, :boolean, default: false
      t.column :ircop, :boolean, default: false



    end
  end

  def self.down
    drop_table :zusers
    remove_index :zusers, :nick
    remove_index :zusers, :role
    remove_index :zusers, :ircop
  end
end