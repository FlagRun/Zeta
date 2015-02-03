# This is considered a dangerous plugin, use it only if you know what you are doing
require_relative '../../lib/helpers/check_user'

module Plugins
  class Oper
    include Cinch::Plugin
    include Cinch::Helpers

    match 'oper', method: :oper_up
    match /kill ([\S]+) (.+)/, method: :oper_kill

    def oper_up(m)
      return unless check_user(m, :operator)
      if Zconf.oper.username && Zconf.oper.password
        @bot.oper(Zconf.oper.password, Zconf.oper.username)
      end
    end

    def oper_kill(m, nick, message)
      return unless m.user.oper
      if @bot.irc.send("KILL #{nick} #{message}")
        m.reply "#{nick}: has been killed by #{m.user.nick} for #{message}"
      end
    end

  end
end

Zeta.config.plugins.plugins.push Plugins::Oper
