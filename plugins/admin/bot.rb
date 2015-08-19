module Admin
  class BotAdmin
    include Cinch::Plugin
    include Cinch::Helpers

    enable_acl(:admin)

    set(
      plugin_name: "BotAdmin",
      help: "Bot administrator-only private commands.\nUsage: `~nick [channel]`;",
    )

    # Regex
    match /set nick (.+)/, method: :nick
    match /set mode (.+)/, method: :mode
    match /die(?: (.+))?/, method: :quit, group: :quit


    # Methods
    def nick(m, nick)
      bot.nick = nick
      synchronize(:nickchange) do
        @bot.handlers.dispatch :admin, m, "My nick got changed from #{@bot.last_nick} to #{@bot.nick} by #{m.user.nick}", m.target
      end
    end

    def mode(m, nick)
      bot.modes = m
    end

    def quit(m, msg=nil)
      msg ||= m.user.nick
      @bot.handlers.dispatch :admin, m, "I am being shut down NOW!#{" - Reason: " + msg unless msg.nil?}", m.target
      sleep 2
      bot.quit(msg)
    end

  end
end


# AutoLoad
Zeta.config.plugins.plugins.push Admin::BotAdmin