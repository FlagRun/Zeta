module Admin
  class BotIgnore
    include Cinch::Plugin
    include Cinch::Helpers

    enable_acl(:operator)

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


    # Methods
    def ignore_user(m, nickname)
      nickname.rstrip!
      return m.reply("You can't ignore yourself") if m.user.nick == nickname
      query_user = User(nickname)
      if m.channel.users.member?(query_user)
        u = find_user(query_user)
        puts u
        if u
          return m.reply("#{nickname} is already being ignored") if u.ignore

          o = find_user(m)

          if o.access > u.access
            Zuser.where(id: u.id).update(ignore: true)
            m.action_reply "is now ignoring #{nickname}"
          elsif o.access < u.access
            m.action_reply "#{nickname} has higher access, cannot ignore!"
          else
            m.reply "#{nickname} cannot be ignored"
          end
        end
      else
        m.reply "#{nickname} isn't currently in channel"
      end
    end

    def unignore_user(m, nickname)
      nickname.rstrip!
      return m.reply("You can't unignore yourself") if m.user.nick == nickname
      query_user = User(nickname)
      if m.channel.users.member?(query_user)
        u = find_user(query_user)
        if u
          return m.reply("#{nickname} isn't being ignored") unless u.ignore

          o = find_user(m)
          if o.access > u.access
            Zuser.where(id: u.id).update(ignore: false)
            m.action_reply "is now no longer ignoring #{nickname}"
          elsif o.access < u.access
            m.action_reply "#{nickname} has higher access, cannot unignore!"
          else
            m.reply "#{nickname} cannot be unignored"
          end
        end
      else
        m.reply "#{nickname} isn't currently in channel"
      end
    end

    def disable_channel(m, channel=nil)
      if channel
        c = find_channel(Channel(channel))
        if c
          return m.reply('Channel is currently disabled') if c.disabled
          if Zchannel.where(id: c.id).update(disabled: true)
            m.action_reply "has disabled #{c.channel.name} buffer"
          else
            m.reply "Unable to Disable channel #{c.channel.name}"
          end
        end
      else
        c = find_channel(m)
        return m.reply('Channel is currently disabled') if c.disabled
        if Zchannel.where(id: c.id).update(disabled: true)
          m.action_reply "has disabled #{m.channel} buffer"
        else
          m.reply "Unable to disable channel #{m.channel.name}"
        end
      end
    end

    def enable_channel(m, channel=nil)
      if channel
        c = find_channel(Channel(channel))
        if c
          return m.reply('Channel is currently enabled') unless c.disabled
          if Zchannel.where(id: c.id).update(disabled: false)
            m.action_reply "has enabled #{c.channel.name} buffer"
          else
            m.reply "Unable to enabled channel #{c.channel.name}"
          end
        end
      else
        c = find_channel(m)
        return m.reply('Channel is currently enabled') unless c.disabled
        if Zchannel.where(id: c.id).update(disabled: false)
          m.action_reply "has enabled #{m.channel} buffer"
        else
          m.reply "Unable to enabled channel #{m.channel.name}"
        end
      end

    end

  end
end


# AutoLoad
Zeta.config.plugins.plugins.push Admin::BotIgnore