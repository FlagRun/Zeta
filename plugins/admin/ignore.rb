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

    match /crash (.+)/, method: :ignore_channel
    match /sleep (.+)/, method: :ignore_channel
    match 'crash', method: :ignore_channel
    match 'sleep', method: :ignore_channel

    match /overide (.+)/, method: :unignore_channel
    match /wake (.+)/, method: :unignore_channel
    match 'overide', method: :unignore_channel
    match 'wake', method: :unignore_channel

    # Methods
    def ignore_user(m, user)
      return m.reply("Must specify a user to ignore!") unless user
      whois = User(user)
      if whois.host && whois.nick == m.user.nick
        if u = find_user(whois)
          o = find_user(m)
          if o.access > u.access
            Zuser.where(id: u.id).update(ignore: true)
            m.action_reply "is now ignoring #{user}"
          elsif o.access < u.access
            m.action_reply "#{user} has higher access, cannot ignore!"
          else
            m.reply "#{user} cannot be ignored"
          end

        end
      end
    end

    def unignore_user(m, user)
      return unless check_user(m, :operator)
      if Zignore.users.split(' ').include?(user)
        Zignore.users.sub!(user, '')
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
        Zignore.channels.sub!(channel, '')
        Zignore.channels.strip!
        m.action_reply "sleepily, Wakes up in #{channel}... "
      else
        Zignore.channels.sub!(m.channel, '')
        Zignore.channels.strip!
        m.action_reply "Bolts upright in #{m.channel}"
      end
    end

  end
end


# AutoLoad
Zeta.config.plugins.plugins.push Admin::BotIgnore