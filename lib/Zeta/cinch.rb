require 'cinch'

Bot = Cinch::Bot.new do
  configure do |c|
    c.nick                      = Config.nickname
    c.nicks                     = Config.nicks.split(',')
    c.user                      = Config.username
    c.realname                  = Config.realname
    c.sasl.username             = Config.sasl_username
    c.sasl.password             = Config.sasl_password
    c.server                    = Config.server
    c.password                  = Config.password
    c.port                      = Config.port
    c.ssl.use                   = Config.ssl
    c.max_messages              = Config.max_messages
    c.messages_per_second       = Config.messages_per_second
    c.modes                     = Config.modes.split(',')
    c.channels                  = Config.channels.split(',')
    c.plugins.prefix            = /^#{Config.prefix}/
  end

  # Execute on confirmation of connection
  on :connect do
    # Gain operator privileges if oper username and password are set in config
    if Config.oper_username && Config.oper_password
      if !Config.oper_password.empty?
        @bot.oper(Config.oper_password, Config.oper_username)
      end
    end

  end

end


