module Admin
  class BotAdmin
    include Cinch::Plugin

    set(
      plugin_name: "BotAdmin",
      help: "Bot administrator-only private commands.\nUsage: `~nick [channel]`;",
      prefix: /^\?/)

    match /nick (.+)/, method: :nick
    def nick(m, nick)
      return unless get_user(m).is_admin?
      bot.nick = nick
      synchronize(:nickchange) do
        @bot.handlers.dispatch :admin, m, "My nick got changed from #{@bot.last_nick} to #{@bot.nick} by #{m.user.nick}", m.target
      end
    end

    match /mode (.+)/, method: :mode
    def mode(m, nick)
      return unless get_user(m).is_admin?
      bot.modes = m
    end

    match /e (.+)/, method: :boteval
    match /eval (.+)/, method: :boteval
    def boteval(m, s)
      return unless get_user(m).is_owner?
      eval(s)
    rescue => e
      m.user.msg "eval error: %s\n- %s (%s)" % [s, e.message, e.class.name]
    end

    match /ereturn (.+)/, method: :botevalreturn
    match /er (.+)/, method: :botevalreturn
    def botevalreturn(m, s)
      return unless get_user(m).is_owner?
      return m.reply eval(s)
    rescue => e
      m.user.msg "eval error: %s\n- %s (%s)" % [s, e.message, e.class.name]
    end

    match /evalmsg (.+)/, method: :botevalmsg
    match /em (.+)/, method: :botevalmsg
    def botevalmsg(m, s)
      return unless get_user(m).is_owner?
      return m.user.msg eval(s)
    rescue => e
      m.user.msg "eval error: %s\n- %s (%s)" % [s, e.message, e.class.name]
    end

  end
end