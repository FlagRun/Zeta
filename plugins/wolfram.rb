require 'cinch'
require 'wolfram-alpha'
require 'cgi'

class Wolfram
  include Cinch::Plugin
  # plugin "wolfram"

  match /((what|how) .+)/

  def self.search(query)
    wolfram = WolframAlpha::Client.new(Zsecret.key.wolfram, options = {:timeout => 1})

    response = wolfram.compute(query)
    if response.result
      response.result_as_text
    else
      "Sorry, I've no idea"
    end
  end

  def execute(m, query)
    m.reply self.class.search(query), true
  end
end

# AutoLoad
# Zeta.config.plugins.plugins.push Plugins::Wolfram