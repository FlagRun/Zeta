bot = Cinch::Bot.new do
  configure do |c|
    c.nick              = ENV['BOT_NICK']
    c.nicks             = ENV['BOT_NICKS'].split(' ')
    c.user              = ENV['BOT_USERNAME']
    c.realname          = ENV['BOT_REALNAME']
    c.sasl.username     = ENV['SASL_USERNAME']
    c.sasl.password     = ENV['SASL_PASSWORD']
    c.server            = ENV['BOT_SERVER']
    c.password          = ENV['BOT_SERVER_PASSWORD']
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
    c.plugins.plugins   << Admin::Fifo
    c.plugins.plugins   << Admin::ChannelAdmin
    c.plugins.plugins   << Admin::Plugins

    ##  Admin Options
    c.plugins.options[Admin::Fifo][:path] = File.join(__dir__, '../tmp/bot')


    ## Plugins
    c.plugins.plugins   << Cinch::Plugins::Wikipedia
    c.plugins.plugins   << Cinch::Plugins::Calculate
    c.plugins.plugins   << Cinch::Plugins::Convert
    c.plugins.plugins   << Cinch::Plugins::Quotes
    c.plugins.plugins   << Plugins::UrbanDictionary
    c.plugins.plugins   << Plugins::Forecast
    c.plugins.plugins   << Plugins::Attack
    c.plugins.plugins   << Plugins::Eightball
    c.plugins.plugins   << Plugins::Fnord
    c.plugins.plugins   << Plugins::Disdate
    c.plugins.plugins   << Plugins::JargonFile
    c.plugins.plugins   << Plugins::Porno
    c.plugins.plugins   << Plugins::Rainbow
    c.plugins.plugins   << Plugins::Silly
    c.plugins.plugins   << Plugins::Vote
    c.plugins.plugins   << Plugins::RussianRoulette
    c.plugins.plugins   << Plugins::Macros
    c.plugins.plugins   << Plugins::Dice
    c.plugins.plugins   << Plugins::BotInfo
    c.plugins.plugins   << Plugins::Register
    c.plugins.plugins   << Plugins::BotHelp
    c.plugins.plugins   << Plugins::DCC
    c.plugins.plugins   << Plugins::Movies

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
## Start the bot
bot.start
