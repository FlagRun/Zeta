# Fixture for spec/admin/plugins_spec.rb: second version keeps only a matcher and help.
module Plugins
  class PluginsProbe
    include Cinch::Plugin

    set help: 'probe v2 help'

    match 'probe', method: :probe

    def probe(m) = m.reply('probe v2')
  end
end

Bot.config.plugins.options.delete(Plugins::PluginsProbe)
