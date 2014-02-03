require 'dotenv'
require 'active_record'
require 'yaml'

Dotenv.load

task :default => :migrate

desc "Migrate the database through scripts in db/migrate. Target specific version with VERSION=x"
task :migrate => :environment do
  ActiveRecord::Migrator.migrate('db/migrate', ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
end

task :environment do
  ActiveRecord::Base.establish_connection(
      adapter:  ENV['DB_ADAPTER'],
      database: ENV['DB_DATABASE'],
      username: ENV['DB_USERNAME'],
      password: ENV['DB_PASSWORD'],
      host:     ENV['DB_HOSTNAME']
  )
  ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'a'))
end