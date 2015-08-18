module Plugins
  class Meme
    include Cinch::Plugin
    include Cinch::Helpers

    enable_acl

    set(
        plugin_name: "MeMe",
        help:        "Display a meme?.\nUsage: `?m <meme>`",
    )

    # Regex
    match /m (.+)/, method: :find_meme


    # Initialization
    def initialize(*args)
      @meme = load_locale('meme')
      super
    end

    # Methods
    def find_meme(m, query)
      query.strip!

      return help_meme(m) if query == 'help'
      return reload_meme(m) if query == 'reload'
      return m.reply('Unknown meme - Use ?m help') unless @meme.has_key?(query)

      m.reply "Got Meme? → #{@meme[query].sample}"
    end

    # Private
    private
    def help_meme(m)
      m.reply "Currently accepted meme's are #{@meme.keys.join(',')}."
    end

    def reload_meme(m)
      return unless check_user(m, :admin)
      # return unless check_channel(m)
      begin
        # @macros = YAML::load_file($root_path + '/locales/macros.yml')
        @meme = load_locale 'meme'
        m.user.notice "Meme's have been reloaded."
      rescue
        m.user.notice "Reloading macros has failed: #{$!}"
      end
    end

  end
end


# AutoLoad
Zeta.config.plugins.plugins.push Plugins::Meme