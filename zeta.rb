$:.unshift(File.expand_path('lib', __FILE__))
$root_path = File.dirname(File.absolute_path(__FILE__))

require 'libxml'
require 'require_all'
require 'cinch'
require 'open-uri'
require 'nokogiri'
require 'json'
require 'ostruct'
require 'yaml'
require 'recursive_open_struct'

# Load Config Data
Zconf   = RecursiveOpenStruct.new( YAML.load_file($root_path + '/config/config.yml') )
Zsec = RecursiveOpenStruct.new( YAML.load_file($root_path + '/config/secret.yml') )

# Initilize the rest of the bot
require_all "#{$root_path}/config/initializers/*.rb"

Zeta = Cinch::Bot.new do
  configure do |c|
    c.nick              = Zconf.bot.nick
    c.nicks             = Zconf.bot.nicks.split(' ')
    c.user              = Zconf.bot.username
    c.realname          = Zconf.bot.realname
    c.sasl.username     = Zconf.sasl.username
    c.sasl.password     = Zconf.sasl.password
    c.server            = Zconf.server.hostname
    c.password          = Zconf.server.password
    c.port              = Zconf.server.port
    c.ssl.use           = Zconf.server.ssl

    c.modes             = Zconf.server.modes.split(' ')
    c.channels          = Zconf.server.channels.split(' ')
    c.plugins.prefix    = /^!/
  end
end

# Load Plugins
require_all "#{$root_path}/plugins/**/*.rb"

## Start the bot  IF NOT IRB/RIPL
unless defined?(IRB) || defined?(Ripl)
  Zeta.start
end

