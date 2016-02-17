module Plugins
  class Echo
    include Cinch::Plugin

    enable_acl(:voice)

    match /echo (.+)/, method: :echoed

    def echoed(m,s)
      m.reply s
    end

  end
end
Bot.config.plugins.plugins.push Plugins::Echo