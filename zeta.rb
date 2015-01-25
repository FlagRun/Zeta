$:.unshift(File.expand_path('lib', __FILE__))
$root_path = File.dirname(File.absolute_path(__FILE__))

require 'require_all'
require 'cinch'
require 'open-uri'
require 'rest-client'
require 'nokogiri'
require 'json'
require 'ostruct'
require 'yaml'
require 'hashie'
require 'recursive_open_struct'

# Load Config Data
# Zconf     =   Hashie::Mash.new( YAML.load_file($root_path + '/config/config.yml') ) rescue OpenStruct.new
# Zsec      =   Hashie::Mash.new( YAML.load_file($root_path + '/config/secret.yml') ) rescue OpenStruct.new
# Zignore   =   Hashie::Mash.new( YAML.load_file($root_path + '/data/ignore.yml')   ) rescue OpenStruct.new
# Zusers    =   Hashie::Mash.new( YAML.load_file($root_path + '/data/users.yml')    ) rescue OpenStruct.new
Zconf   = Hashie::Mash.new YAML.load_file($root_path + '/config/config.yml')
Zsec    = Hashie::Mash.new YAML.load_file($root_path + '/config/secret.yml')
Zignore = Hashie::Mash.new YAML.load_file($root_path + '/config/ignore.yml')
Zusers  = Hashie::Mash.new YAML.load_file($root_path + '/config/users.yml')

# Initilize the rest of the bot
require_all "#{$root_path}/config/initializers/*.rb"

Zeta = Cinch::Bot.new do
  configure do |c|
    c.nick                      = Zconf.bot.nick
    c.nicks                     = Zconf.bot.nicks.split(' ')
    c.user                      = Zconf.bot.username
    c.realname                  = Zconf.bot.realname
    c.sasl.username             = Zconf.sasl.username
    c.sasl.password             = Zconf.sasl.password
    c.server                    = Zconf.server.hostname
    c.password                  = Zconf.server.password
    c.port                      = Zconf.server.port
    c.ssl.use                   = Zconf.server.ssl
    c.max_messages              = Zconf.server.max_messages
    c.messages_per_second       = Zconf.server.messages_per_second

    c.modes             = Zconf.server.modes.split(' ')
    c.channels          = Zconf.server.channels.split(' ')
    c.master            = Zconf.master
    c.plugins.prefix    = /^\?/
  end
end

# Load Plugins
require_all "#{$root_path}/plugins/**/*.rb"

## Start the bot  IF NOT IRB/RIPL
unless defined?(IRB) || defined?(Ripl)
  Zeta.start
end

