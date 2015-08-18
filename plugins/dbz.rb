module Plugins
  class DBZ
    include Cinch::Plugin
    include Cinch::Helpers

    enable_acl

    self.plugin_name = 'DragonBall Z!'
    self.help = "It's Over Nine Thousand!"

    # Regex
    match /(^9000$|overninethousand|ninethousand|Over\ Nine\ Thousand|Over\ 9000)/,
          use_prefix: false, method: :randomquote

    # Initialization
    def initialize(*args)
      @sample = load_locale('dbz')
      super
    end

    # Methods
    def randomquote(msg)
      msg.reply @sample['over9k'].sample
    end

  end

end

# AutoLoad
Zeta.config.plugins.plugins.push Plugins::DBZ