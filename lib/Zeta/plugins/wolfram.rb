require 'crack'
require 'cgi/escape'

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
      url = "https://api.wolframalpha.com/v2/query?input=#{CGI.escape(query)}&appid=#{CGI.escape(Config.secrets[:wolfram].to_s)}&primary=true&format=plaintext"
      data = Crack::XML.parse(RestClient.get(url).body)

      pod0, pod1 = pod_texts(data['queryresult'])
      return m.reply('Unable to get a results') if pod0.nil? || pod0.empty?

      if pod1.lines.count > 2
        m.user.send "# Wolfram Results #\n #{pod0}\n #{pod1}", true
      elsif pod0.length > 400
        m.user.send("#{pod0} #{pod1}", true)
      elsif pod1.empty?
        m.reply pod0
      else
        m.reply "#{pod0} = #{pod1}"
      end
    rescue RestClient::Unauthorized, RestClient::Forbidden
      error 'Wolfram Alpha rejected the configured appid (Config.secrets[:wolfram])'
      m.action_reply "isn't currently authorized to do that"
    rescue StandardError => e
      error "Wolfram Alpha query failed: #{e.class.name}: #{e.message}"
      m.reply 'Unable to get a results'
    end

    private

    # Crack returns a Hash for a single pod/subpod and an Array when there are several
    def pod_texts(result)
      Array.wrap(result && result['pod']).map do |pod|
        Array.wrap(pod['subpod']).map { |sub| sub && sub['plaintext'].to_s.strip }.compact.reject(&:empty?).join("\n")
      end + ['', ''] # always at least an input and result slot
    end
  end
end

# AutoLoad
Bot.config.plugins.plugins.push Plugins::Wolfram