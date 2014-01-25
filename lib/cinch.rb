require 'cinch'
require 'dotenv'
require 'require_all'

Dotenv.load

require_relative 'core/admin'
require_relative 'core/load'
require_relative 'core/models'
require_relative 'core/plugins'

# Start the bot
bot = Cinch::Bot.new do
  configure do |c|
    c.nick              = ENV['BOT_NICK']
    c.user              = ENV['BOT_USERNAME']
    c.realname          = ENV['BOT_REALNAME']
    c.sasl.username     = ENV['SASL_USERNAME']
    c.sasl.password     = ENV['SASL_PASSWORD']
    c.server            = ENV['BOT_SERVER']
    c.port              = ENV['BOT_SERVER_PORT']
    c.ssl.use           = ENV['BOT_SERVER_SSL']

    c.modes             = %w{+B -x}
    c.channels          = %w{#flagrun #ruby #gentoo #linux}
    c.plugins.prefix    = /^./

    ## Authentication


    ##  Admin Plugins
    c.plugins.plugins   << Admin::BotAdmin
    c.plugins.plugins   << Admin::UserAdmin
    c.plugins.plugins   << Admin::ChatlogAdmin
    c.plugins.plugins   << Admin::ChannelAdmin


    ##  Admin Options


    ## Plugins
    c.plugins.plugins   << Plugins::Attack
    c.plugins.plugins   << Plugins::Tell
    c.plugins.plugins   << Plugins::Eightball
    c.plugins.plugins   << Plugins::Fnord
    c.plugins.plugins   << Plugins::Disdate
    c.plugins.plugins   << Plugins::JargonFile
    c.plugins.plugins   << Plugins::PluginManager
    c.plugins.plugins   << Plugins::Porno
    c.plugins.plugins   << Plugins::Rainbow
    c.plugins.plugins   << Plugins::Silly
    c.plugins.plugins   << Plugins::UrbanDictionary
    c.plugins.plugins   << Plugins::Vote
    c.plugins.plugins   << Plugins::RussianRoulette
    c.plugins.plugins   << Plugins::Macros
    c.plugins.plugins   << Plugins::Dice
    c.plugins.plugins   << Plugins::BotInfo
    c.plugins.plugins   << Plugins::UserPlugin

    ## Plugins Options


  end

  ## Chatlog
  on :message do |msg|
    if not msg.channel.nil?
      Chatlog.create(channel: msg.channel.name, time: msg.time, nick: msg.user.nick, msg: msg.message )
    end
  end


end
### Begin
bot.start
