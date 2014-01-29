require 'cinch'
require 'cinch/plugins/forecast'
require 'cinch/plugins/quotes'
require 'cinch-convert'
require 'cinch-calculate'
require 'cinch-wikipedia'

require 'dotenv'
require 'open-uri'
require 'nokogiri'

Dotenv.load

require_relative 'core/admin'
require_relative 'core/models'
require_relative 'core/plugins'

# Start the bot
bot = Cinch::Bot.new do
  configure do |c|
    c.nick              = ENV['BOT_NICK']
    c.nicks             = ENV['BOT_NICKS'].split(' ')
    c.user              = ENV['BOT_USERNAME']
    c.realname          = ENV['BOT_REALNAME']
    c.sasl.username     = ENV['SASL_USERNAME']
    c.sasl.password     = ENV['SASL_PASSWORD']
    c.server            = ENV['BOT_SERVER']
    c.port              = ENV['BOT_SERVER_PORT']
    c.ssl.use           = ENV['BOT_SERVER_SSL']

    c.modes             = ENV['BOT_MODES'].split(' ')
    #c.channels          = %w{#flagrun #ruby #gentoo #linux}
    c.channels          = ENV['BOT_CHANNELS'].split(' ')
    c.plugins.prefix    = /^!/

    ## Authentication


    ##  Admin Plugins
    c.plugins.plugins   << Admin::BotAdmin
    c.plugins.plugins   << Admin::UserAdmin
    c.plugins.plugins   << Admin::ChatlogAdmin
    c.plugins.plugins   << Admin::ChannelAdmin


    ##  Admin Options


    ## Plugins
    c.plugins.plugins   << Cinch::Plugins::Forecast
    c.plugins.plugins   << Cinch::Plugins::Wikipedia
    c.plugins.plugins   << Cinch::Plugins::Calculate
    c.plugins.plugins   << Cinch::Plugins::Convert
    c.plugins.plugins   << Cinch::Plugins::Quotes
    c.plugins.plugins   << Plugins::Attack
    # c.plugins.plugins   << Plugins::Tell
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
    c.plugins.options[Cinch::Plugins::Calculate][:units_path]   = '/usr/bin/units'
    c.plugins.options[Cinch::Plugins::Convert][:units_path]     = '/usr/bin/units'
    c.plugins.options[Cinch::Plugins::Quotes][:quotes_file]     = File.join(__dir__, 'locales/quotes.yml')



  end

  ### Zchatlog
  #on :message do |msg|
  #  if not msg.channel.nil?
  #    Zchatlog.create(channel: msg.channel.name, time: msg.time, nick: msg.user.nick, msg: msg.message )
  #  end
  #end


end
### Begin
bot.start
