require 'mongoid'
Mongoid.connect_to('zbot')

require 'redis'
$redis = Redis.new(:host => '127.0.0.1', :port => 6380)

require_relative '../models/quote'
require_relative '../models/user'
require_relative '../models/tell'
require_relative '../models/chatlog'
