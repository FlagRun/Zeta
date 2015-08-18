module Plugins
  class Whois
    include Cinch::Plugin
    include Cinch::Helpers

    # enable_acl

    self.plugin_name = 'Whois'
    self.help        = 'Resync your user'

    # Regex
    match 'whois', method: :do_whois

    # Methods
    def do_whois(m)
      m.user.refresh
      m.user.notice "Refreshing #{m.user.nick}"
    end

  end

end

# AutoLoad
Zeta.config.plugins.plugins.push Plugins::Whois