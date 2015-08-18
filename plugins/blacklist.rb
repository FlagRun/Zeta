require 'dnsbl/client'

module Plugins
  class BlackList
    include Cinch::Plugin
    include Cinch::Helpers

    enable_acl

    self.plugin_name = 'DNS Blacklist'
    self.help = '?dnsbl <host>'

    # Regex
    match /dnsbl (.+)/, method: :dnsbl_lookup
    match /blacklist (.+)/, method: :dnsbl_lookup

    # Methods
    def dnsbl_lookup(m, host)
      client = DNSBL::Client.new
      query = client.lookup(host.rstrip)

      if query.empty?
        m.reply "No Results Found (#{host})"
      elsif query.last.dnsbl == 'URIBL' && query.last.meaning == '127.0.0.1'
        m.reply "No Results Found (#{host})"
      else
        m.reply "Listed ⁘ #{host} ⁜ #{query.last.meaning} ⁜ Hits: #{query.count}"
      end
    end

  end

end

# AutoLoad
Zeta.config.plugins.plugins.push Plugins::BlackList