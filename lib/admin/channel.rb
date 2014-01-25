module Admin
  class ChannelAdmin
    include Cinch::Plugin

    set(
      plugin_name: 'ChannelAdmin',
      help: "Bot administrator-only private commands.\nUsage: `~join [channel]`; `~part [channel] <reason>`; `~quit [reason]`;",
      prefix: /^~/
    )

    match /join (.+)/, method: :join
    def join(m, channel)
      return unless getuser(m).is_admin?
      channel.split(", ").each {|ch|
        Channel(ch).join
        @bot.handlers.dispatch :admin, m, "Attempt to join #{ch.split[0]} by #{m.user.nick}...", m.target
      }
    end

    match /part(?: (\S+))?(?: (.+))?/, method: :part, group: :part
    def part(m, channel=nil, msg=nil)
      return unless getuser(m).is_admin?
      channel ||= m.channel.name
      msg ||= m.user.nick
      Channel(channel).part(msg) if channel
      @bot.handlers.dispatch :admin, m, "Parted #{channel}#{" - #{msg}" unless msg.nil?}", m.target
    end

    match /quit(?: (.+))?/, method: :quit, group: :quit
    def quit(m, msg=nil)
      return unless getuser(m).is_admin?
      msg ||= m.user.nick
      @bot.handlers.dispatch :admin, m, "I am being shut down NOW!#{" - Reason: " + msg unless msg.nil?}", m.target
      sleep 2
      bot.quit(msg)
    end

    private
    def getuser(m)
      User.where(nick: m.user.nick).first || User.new
    end

  end

end