# Fixture for spec/admin/plugins_spec.rb: first version of a plugin that uses
# every class-level setting Admin::Plugins resets when unloading.
module Plugins
  class PluginsProbe
    include Cinch::Plugin

    set plugin_name: 'probeone', help: 'probe v1 help', prefix: /^!/, suffix: /\?$/,
        react_on: :channel, required_options: [:token]

    hook :pre, for: [:match], method: :gate
    listen_to :join, method: :greet
    ctcp :probe
    timer 60, method: :tick

    match 'probe', method: :probe

    def gate(m) = m.user.nick != 'carol'
    def greet(m) = m.reply("welcome #{m.user.nick}")
    def ctcp_probe(m) = m.ctcp_reply('probe v1')
    def tick = Channel('#logs').send('tick')
    def probe(m) = m.reply('probe v1')
  end
end

Bot.config.plugins.options[Plugins::PluginsProbe] = { token: 'x' }
