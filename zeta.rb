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
Zconf   = Hashie::Mash.new YAML.load_file($root_path + '/config/config.yml')
Zsec    = Hashie::Mash.new YAML.load_file($root_path + '/config/secret.yml')
Zignore = Hashie::Mash.new YAML.load_file($root_path + '/config/ignore.yml')
Zusers  = Hashie::Mash.new YAML.load_file($root_path + '/config/users.yml')

# Initilize the rest of the bot
require_all "#{$root_path}/lib/initializers/*.rb"

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

  # Execute on confirmation of connection
  on :connect do

    # Gain operator privileges if oper username and password are set in config
    if Zconf.oper.username && Zconf.oper.password
      @bot.oper(Zconf.oper.password, Zconf.oper.username)
    end

  end

end

# Load Admin Plugins
require_all "#{$root_path}/plugins/admin/*.rb"

# Load Plugins
require_all "#{$root_path}/plugins/*.rb"

# Require Network Specific Plugins
require_all "#{$root_path}/plugins/network/#{Zconf.server.network}/*.rb"

## Start the bot  IF NOT IRB/RIPL
unless defined?(IRB) || defined?(Ripl)
  # Log all errors to /log/error.log
  Zeta.loggers << Cinch::Logger::FormattedLogger.new(File.open("#{$root_path}/log/error.log", "a"))
  Zeta.loggers.last.level = :error
  Zeta.start
end

