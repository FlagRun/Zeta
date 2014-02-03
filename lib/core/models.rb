require 'active_record'

ActiveRecord::Base.establish_connection(
    adapter:  ENV['DB_ADAPTER'],
    database: ENV['DB_DATABASE'],
    username: ENV['DB_USERNAME'],
    password: ENV['DB_PASSWORD'],
    host:     ENV['DB_HOSTNAME']
)

require_relative '../models/zquote'
require_relative '../models/zuser'
require_relative '../models/ztell'