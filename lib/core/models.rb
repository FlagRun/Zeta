require 'mongoid'
Mongoid.connect_to('zbot')

require 'redis'
$redis = Redis.new(:host => '127.0.0.1')

require_relative '../models/zquote'
require_relative '../models/zuser'
require_relative '../models/ztell'
require_relative '../models/zchatlog'
