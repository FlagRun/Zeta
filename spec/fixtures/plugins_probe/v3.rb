# Fixture for spec/admin/plugins_spec.rb: third version drops the help text too.
module Plugins
  class PluginsProbe
    include Cinch::Plugin

    match 'probe', method: :probe

    def probe(m) = m.reply('probe v3')
  end
end
