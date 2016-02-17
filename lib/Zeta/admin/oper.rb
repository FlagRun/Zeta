# This is considered a dangerous plugin, use it only if you know what you are doing
module Admin
  class Oper
    include Cinch::Plugin
    include Cinch::Helpers

    enable_acl(:oper)

    # Regex
    match 'operup', method: :oper_up
    match /kill ([\S]+) (.+)/, method: :oper_kill
    match /clearchan (.+) (true|yes)/, method: :oper_clearchan

    # Methods
    def oper_up(m)
      if Config.oper_username && Config.oper_password
        @bot.oper(Config.oper_password, Config.oper_username)
      end
    end

    def oper_kill(m, nick, message)
      return if User(nick).oper?
      if @bot.irc.send("KILL #{nick} #{message}")
        m.reply "#{nick}: has been killed by #{m.user.nick} for #{message}"
      end
    end

    def oper_clearchan(m, chan, confirm=false)
      if confirm == 'yes' || confirm == 'true'
        Channel(chan).join
        User('OperServ').send("mode #{chan} +o #{Zeta}")
        User('OperServ').send("mode #{chan} +mi")
        Channel(chan).send('This channel is being cleared')

        number_killed = 0
        Channel(chan).users.each_key do |u|
          if u != Zeta
            number_killed += 1
            @bot.irc.send("KILL #{u.nick} This channel is being cleared")
          end
        end
        m.safe_reply "#{chan} has been cleared, #{number_killed} clients killed"

      end
    end

  end
end

Bot.config.plugins.plugins.push Admin::Oper