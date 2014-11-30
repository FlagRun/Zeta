module Plugins
  class DBZ
    include Cinch::Plugin
    include Cinch::Helpers

    self.plugin_name = 'DragonBall Z!'
    self.help = "It's Over Nine Thousand!"

    match /(9k|^9...|overninethousand|ninethousand|Over\ Nine\ Thousand|Over\ 9000)/,
          use_prefix: false, method: :randomquote

    def initialize(*args)
      @sample = YAML::load_file($root_path + '/locales/dbz.yml')
      super
    end

    def randomquote(msg)
      return unless check_user(msg)
      return unless check_channel(msg)
      msg.reply @sample['over9k'].sample
    end

  end

end

# AutoLoad
Zeta.config.plugins.plugins.push Plugins::DBZ