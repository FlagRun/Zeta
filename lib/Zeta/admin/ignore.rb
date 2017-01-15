module Admin
  class Ignore
    include Cinch::Plugin
    include Cinch::Helpers

    enable_acl(:operator, true)

    set(
        plugin_name: "BotAdmin",
        help:        "Bot administrator-only private commands.\nUsage: `~nick [channel]`;",
    )

    # Regex
    match /ignore (.+)/, method: :ignore_user
    match /unignore (.+)/, method: :unignore_user

    match /disable (.+)/, method: :disable_channel
    match /enable (.+)/, method: :enable_channel
    match 'disable', method: :disable_channel
    match 'enable', method: :enable_channel

    match 'ignorelist', method: :ignore_list

    def finalize
      save_blacklist()
    end

    # Methods
    def ignore_user(m, nickname)
      nickname.rstrip!
      return m.reply("You can't ignore yourself") if m.user.nick == nickname
      u = User(nickname)
      if m.channel.users.member?(u)
        if Blacklist.users.include? u
          m.reply("#{nickname} is already being ignored")
        else
          Blacklist.users << u.to_s
          m.action_reply "is now ignoring #{nickname}"
        end
      else
        m.reply "#{nickname} isn't currently in channel"
      end
      save_blacklist()
    end

    def unignore_user(m, nickname)
      nickname.rstrip!
      u = User(nickname)
      if Blacklist.users.include?(u.to_s)
        Blacklist.users.delete(u.to_s)
        m.action_reply "is no longer ignoring #{nickname}"
      else
        m.reply "#{nickname} isn't on the ignore list"
      end
      save_blacklist()
    end

    def disable_channel(m, channel=nil)
      if channel
        if Blacklist.channels.include?(channel.to_s)
          m.reply('Channel is currently disabled')
        else
          Blacklist.channels << channel.to_s
          m.action_reply "has disabled #{channel} buffer"
        end
      else
        if Blacklist.channels.include?(m.channel.to_s)
          m.reply('Channel is currently disabled')
        else
          Blacklist.channels << m.channel.to_s.to_s
          m.action_reply "has disabled #{m.channel.to_s} buffer"
        end
      end
      save_blacklist()
    end

    def enable_channel(m, channel=nil)
      if channel
        if Blacklist.channels.include?(channel.to_s)
          Blacklist.channels.delete(channel.to_s)
          m.action_reply "has enabled #{channel} buffer"
        else
          m.reply('Channel is currently enabled')
        end
      else
        if Blacklist.channels.include?(m.channel.to_s)
          Blacklist.channels.delete(m.channel.to_s)
          m.action_reply "has enabled #{m.channel.to_s} buffer"
        else
          m.reply('Channel is currently enabled')
        end
      end
      save_blacklist()
    end

    def ignore_list(m)
      m.reply "Currently ignored users are: #{Blacklist.users.join(', ')}"
    end


  end
end


# AutoLoad
Bot.config.plugins.plugins.push Admin::Ignore