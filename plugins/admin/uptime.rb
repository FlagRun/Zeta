require 'sys/proctable'
require 'action_view'


module Admin
  class BotUptime
    include Cinch::Plugin
    include Cinch::Helpers
    include ActionView::Helpers::DateHelper
    include Sys

    enable_acl(:operator)

    # Regex
    match 'uptime', method: :get_uptime
    match 'sysuptime', method: :get_sysuptime
    match 'users', method: :get_users

    def get_uptime(m)
      p = ProcTable.ps($$)
      start_time = Time.at(p.starttime)
      diff = Time.now - start_time
      m.reply("I have been up for #{time_ago_in_words(Time.now - diff)}.")
    end

    def get_sysuptime(m)
      m.reply(`uptime`)
    end

    def get_users(m)
      m.reply("Shell Users: #{`users`}")
    end

  end
end


# AutoLoad
Zeta.config.plugins.plugins.push Admin::BotUptime