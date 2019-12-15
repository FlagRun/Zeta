module Plugins
  class Noticeme
    include Cinch::Plugin
    include Cinch::Helpers

    # enable_acl

    self.plugin_name = 'Notice ME!'
    self.help        = 'Make sure zeta can see me!'

    # Regex
    match 'noticeme', method: :notice_me

    # Methods
    def notice_me(m)
      m.user.refresh
      m.user.notice "Refreshing #{m.user.nick}"
    end

  end

end

# AutoLoad
Bot.config.plugins.plugins.push Plugins::Noticeme