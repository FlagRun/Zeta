require 'sequel'

# Connection
DB = Sequel.connect(ENV['DATABASE_URL'], :max_connections => 10 )

# Models
require_relative '../models/zquote'
require_relative '../models/zuser'
require_relative '../models/ztell'