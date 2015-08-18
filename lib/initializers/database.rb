require 'sequel'

# Make Connection to Database
DB = Sequel.connect(Zconf.db)

# Load all of the Models
require_all "#{$root_path}/lib/models/*.rb"