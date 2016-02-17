module Admin
  class Channels
    include Cinch::Plugin
    include Cinch::Helpers

    enable_acl(:operator, true)

    set(
        plugin_name: 'ChannelAdmin',
        help: "Bot administrator-only private commands.\nUsage: `?join [channel]`; `?part [channel] <reason>`; `?quit [reason]`;",
    )

    # Regex
    match /join (.+)/, method: :join
    match /part(?: (\S+))?(?: (.+))?/, method: :part, group: :part

    def join(m, channel)
      channel.split(", ").each {|ch|
        Channel(ch).join
        @bot.handlers.dispatch :admin, m, "Attempt to join #{ch.split[0]} by #{m.user.nick}...", m.target
      }
    end

    def part(m, channel=nil, msg=nil)
      channel ||= m.channel.name
      msg ||= m.user.nick
      Channel(channel).part(msg) if channel
      @bot.handlers.dispatch :admin, m, "Parted #{channel}#{" - #{msg}" unless msg.nil?}", m.target
    end

  end

end

# AutoLoad
Bot.config.plugins.plugins.push Admin::Channels