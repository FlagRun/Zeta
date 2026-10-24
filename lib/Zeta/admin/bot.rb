module Admin
  class Bot
    include Cinch::Plugin
    include Cinch::Helpers

    enable_acl(:oper)

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
      old_nick = @bot.nick
      bot.nick = nick
      synchronize(:nickchange) do
        @bot.handlers.dispatch :admin, m, "My nick got changed from #{old_nick} to #{nick} by #{m.user.nick}", m.target
      end
    end

    def mode(m, modes)
      add, remove = [], []
      target = add
      modes.strip.each_char do |c|
        case c
        when '+' then target = add
        when '-' then target = remove
        else target << c
        end
      end
      bot.modes = (bot.modes | add) - remove
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
Bot.config.plugins.plugins.push Admin::Bot