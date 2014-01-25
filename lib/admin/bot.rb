module Admin
  class BotAdmin
    include Cinch::Plugin

    set(
      plugin_name: "BotAdmin",
      help: "Bot administrator-only private commands.\nUsage: `~nick [channel]`;",
      prefix: /^~/)

    match /nick (.+)/, method: :nick
    def nick(m, nick)
      return unless authenticated? m
      bot.nick = nick
      synchronize(:nickchange) do
        @bot.handlers.dispatch :admin, m, "My nick got changed from #{@bot.last_nick} to #{@bot.nick} by #{m.user.nick}", m.target
      end
    end

    match /mode (.+)/, method: :mode
    def mode(m, nick)
      return unless authenticated? m
      bot.modes = m
    end


  end
end