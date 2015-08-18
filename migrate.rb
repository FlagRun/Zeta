$:.unshift(File.expand_path('lib', __FILE__))
$root_path = File.dirname(File.absolute_path(__FILE__))

require 'yaml'
require 'hashie'
require 'sqlite3'

Zconf = Hashie::Mash.new(YAML.load_file($root_path + '/config/config.yml'))
Zsec  = Hashie::Mash.new(YAML.load_file($root_path + '/config/secret.yml'))

system("sequel -m #{$root_path}/db/migrations/ #{Zconf.db}")