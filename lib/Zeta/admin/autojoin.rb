module Admin
  class Autojoin
    include Cinch::Plugin
    include Cinch::Helpers

    # Listeners
    listen_to :invite, method: :join_and_notify

    enable_acl(:nobody)


    # Methods
    def join_and_notify(m)
      if Config.options.key? :join_on_invite
        log2chan("#{m.user.nick} has requested me join #{m.channel}", :notice)
        Channel(m.channel).join
      end
    end

  end
end

# AutoLoad
Bot.config.plugins.plugins.push Admin::Autojoin