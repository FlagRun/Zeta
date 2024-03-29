# This plugin is brought to you by aburdette/cinch-fmylife
# Thank You!

module Plugins
  class Fml
    include Cinch::Plugin
    include Cinch::Helpers

    enable_acl(:nobody)

    set(
        plugin_name: "FuckMyLife",
        help: "Get a random FML.\nUsage: `?fml`",
    )

    match /fml/

    def execute(m)
      m.reply fetch_random_fml, true
    end

    private
    def fetch_random_fml
      url = 'http://www.fmylife.com/random'

      html_body = RestClient.get(url).body

      fml_story = Nokogiri.HTML(html_body).at('article').text.strip
      fml_story[/^Today, (.+) FML/]
    rescue => e
      e.message
    end
  end
end

# AutoLoad
Bot.config.plugins.plugins.push Plugins::Fml