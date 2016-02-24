module Admin
  class Autojoin
    include Cinch::Plugin
    include Cinch::Helpers

    # Listeners
    listen_to :invite, method: :invited

    enable_acl(:nobody)

    # Methods
    def invited(m)
      if Config.options.dig :join_on_invite
        # return false if Blacklist.users.include? m.user.nick.to_s
        # return false if Blacklist.channels.include? m.channel.to_s

        log2chan("#{m.user.nick} has requested me join #{m.channel}", :notice)

        Channel(m.channel).join
      end
    end
  end
end

# AutoLoad
Bot.config.plugins.plugins.push Admin::Autojoin