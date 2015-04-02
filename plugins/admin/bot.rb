module Admin
  class BotAdmin
    include Cinch::Plugin
    include Cinch::Helpers

    set(
      plugin_name: "BotAdmin",
      help: "Bot administrator-only private commands.\nUsage: `~nick [channel]`;",
    )

    # Regex
    match /changenick (.+)/, method: :nick
    match /mode (.+)/, method: :mode
    match /die(?: (.+))?/, method: :quit, group: :quit

    match /e (.+)/, method: :boteval
    match /eval (.+)/, method: :boteval
    match /ereturn (.+)/, method: :botevalreturn
    match /er (.+)/, method: :botevalreturn
    match /evalmsg (.+)/, method: :botevalmsg
    match /em (.+)/, method: :botevalmsg

    match /ignore (.+)/, method: :ignore_user
    match /unignore (.+)/, method: :unignore_user

    match /crash (.+)/, method: :ignore_channel
    match /sleep (.+)/, method: :ignore_channel
    match 'crash', method: :ignore_channel
    match 'sleep', method: :ignore_channel

    match /overide (.+)/, method: :unignore_channel
    match /wake (.+)/, method: :unignore_channel
    match 'overide', method: :unignore_channel
    match 'wake', method: :unignore_channel

    # Methods
    def nick(m, nick)
      return unless check_user(m, :admin)
      bot.nick = nick
      synchronize(:nickchange) do
        @bot.handlers.dispatch :admin, m, "My nick got changed from #{@bot.last_nick} to #{@bot.nick} by #{m.user.nick}", m.target
      end
    end

    def mode(m, nick)
      return unless check_user(m, :admin)
      bot.modes = m
    end

    def quit(m, msg=nil)
      return unless check_user(m, :master)
      msg ||= m.user.nick
      @bot.handlers.dispatch :admin, m, "I am being shut down NOW!#{" - Reason: " + msg unless msg.nil?}", m.target
      sleep 2
      bot.quit(msg)
    end

    def boteval(m, s)
      return unless check_user(m, :owner)
      eval(s)
    rescue => e
      m.user.msg "eval error: %s\n- %s (%s)" % [s, e.message, e.class.name]
    end

    def botevalreturn(m, s)
      return unless check_user(m, :owner)
      return m.reply eval(s)
    rescue => e
      m.user.msg "eval error: %s\n- %s (%s)" % [s, e.message, e.class.name]
    end

    def botevalmsg(m, s)
      return unless check_user(m, :owner)
      return m.user.msg eval(s)
    rescue => e
      m.user.msg "eval error: %s\n- %s (%s)" % [s, e.message, e.class.name]
    end

    def ignore_user(m, user)
      return m.reply("Must specify a user to ignore!") unless user
      return unless check_user(m, :operator)
      if Zusers.admin.split(' ').include?(user) || Zusers.operator.split(' ').include?(user)
        m.reply "#{user} cannot be ignored"
      else
        Zignore.users << " #{user}"
        m.action_reply "is now ignoring #{user} "
      end
    end

    def unignore_user(m, user)
      return unless check_user(m, :operator)
      if Zignore.users.split(' ').include?(user)
        Zignore.users.sub!(user,'')
        Zignore.users.strip!
        m.action_reply "is no longer ignoring #{user}"
      else
        m.action_reply "wasn't ignoring #{user} anyways"
      end
    end

    def ignore_channel(m, channel=nil)
      return unless check_user(m, :operator)
      if channel
        Zignore.channels << " #{channel}"
        m.action_reply "falls asleep on the /dev/pst, drooling all over #{m.channel} buffer..."
      else
        Zignore.channels << " #{m.channel}"
        m.action_reply "falls asleep on the /dev/pst, drooling all over #{m.channel} buffer..."
      end
    end

    def unignore_channel(m, channel=nil)
      return unless check_user(m, :operator)
      if channel
        Zignore.channels.sub!(channel,'')
        Zignore.channels.strip!
        m.action_reply "sleepily, Wakes up in #{channel}... "
      else
        Zignore.channels.sub!(m.channel,'')
        Zignore.channels.strip!
        m.action_reply "Bolts upright in #{m.channel}"
      end
    end

  end
end


# AutoLoad
Zeta.config.plugins.plugins.push Admin::BotAdmin