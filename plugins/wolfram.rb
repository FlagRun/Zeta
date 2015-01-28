require 'crack'

module Plugins
  class Wolfram
    include Cinch::Plugin
    include Cinch::Helpers
    include ActionView::Helpers::DateHelper


    self.plugin_name = 'Wolfram Alpha plugin'
    self.help = 'WIP'

    match /wolfram (.+)/, method: :calculate
    match /wolframalpha (.+)/, method: :calculate
    match /calc (.+)/, method: :calculate

    def calculate(msg, query)
      return unless check_user(msg)
      return unless check_channel(msg)

      RestClient.proxy = ENV['http_proxy']
      url = URI.encode "http://api.wolframalpha.com/v2/query?input=#{query}&appid=#{Zsec.wolfram}&primary=true&format=plaintext"
      request = RestClient.get(url)
      data = Crack::XML.parse(request)
      answer = data['queryresult']['pod'][1]['subpod']['plaintext']
      msg.user.notice "# Wolfram Results #\n #{answer}"

    end

  end
end

# AutoLoad
Zeta.config.plugins.plugins.push Plugins::Wolfram