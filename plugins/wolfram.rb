require 'crack'

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

    def calculate(msg, query)
      url = URI.encode "http://api.wolframalpha.com/v2/query?input=#{query}&appid=#{Zsec.wolfram}&primary=true&format=plaintext"
      # request = RestClient.get(url)
      request = open(url).read
      data = Crack::XML.parse(request)
      answer = data['queryresult']['pod'][1]['subpod']['plaintext']
      msg.user.send "# Wolfram Results #\n #{answer}", true

    end

  end
end

# AutoLoad
Zeta.config.plugins.plugins.push Plugins::Wolfram