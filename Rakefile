require 'dotenv'
require 'yaml'

Dotenv.load

namespace :db do

  desc 'Run migrations'
  task :migrate, [:version] do |t, args|
    require 'sequel'
    Sequel.extension :migration
    db = Sequel.connect(ENV['DATABASE_URL'])
    if args[:version]
      puts "Migrating to version #{args[:version]}"
      Sequel::Migrator.run(db, File.join(__dir__, 'db/migrate'), target: args[:version].to_i)
    else
      puts 'Migrating to latest'
      Sequel::Migrator.run(db, File.join(__dir__, 'db/migrate'))
    end
  end

end