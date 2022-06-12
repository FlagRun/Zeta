require 'crack'
require 'cgi'

module Plugins
  class Wolfram
    include Cinch::Plugin
    include Cinch::Helpers
    include ActionView::Helpers::DateHelper
    enable_acl


    self.plugin_name = 'Wolfram Alpha plugin'
    self.help = 'WIP'

    match /wolfram (.+)/, method: :calculate
    match /wolframalpha (.+)/, method: :calculate
    match /calc (.+)/, method: :calculate

    def calculate(m, query)
      # Rescue in case something goes wrong
      begin
        url = "http://api.wolframalpha.com/v2/query?input=#{CGI.escape(query)}&appid=#{Config.secrets[:wolfram]}&primary=true&format=plaintext"
        request = RestClient.get(url).body

        data = Crack::XML.parse(request)

        pod0 = data['queryresult']['pod'][0]['subpod']['plaintext'].strip
        pod1 = data['queryresult']['pod'][1]['subpod']['plaintext'].strip

        return 'Unable to get a results' if pod0.nil?

        if pod1.lines.count > 2
          m.user.send "# Wolfram Results #\n #{pod0}\n #{pod1}", true
        elsif pod0.length > 400
          m.user.send("#{pod0} #{pod1}", true)
        else
          m.reply "#{pod0} = #{pod1}"
        end
      rescue
        m.reply 'Unable to get a results'
      end
    end
  end
end

# AutoLoad
Bot.config.plugins.plugins.push Plugins::Wolfram