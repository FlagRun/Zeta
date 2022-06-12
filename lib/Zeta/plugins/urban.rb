require 'open-uri'

module Plugins
  class UrbanDictionary
    include Cinch::Plugin
    include Cinch::Helpers

    enable_acl(:nobody)

    set(
        plugin_name: 'UrbanDictionary',
        help: "Urban Dictionary -- Grabs a term from urbandictionary.com.\nUsage: `?ud <term>`; `?wotd`;"
    )

    match /urban (.*)/, method: :query
    match /ud (.*)/,    method: :query
    match /wotd/,       method: :wotd
    match "ud",         method: :wotd

    def query(m, query)
      m.reply "UD↦ #{search(query)}"
    end


    def wotd(m)
      parser = URI::Parser.new
      url = parser.escape("http://www.urbandictionary.com/")

      doc = Nokogiri.HTML(
          RestClient.get(url).body
      )
      word = doc.at_css('.word').text.strip[0..40]
      meaning = doc.at_css('.meaning').text.strip[0..450] + "... \u263A"
      m.reply "UD↦ #{word} -- #{meaning}"
    end

    private
    def search(query)
      parser = URI::Parser.new
      url = parser.escape "http://api.urbandictionary.com/v0/define?term=#{query}"

      # Load API data
      data = JSON.parse(
          RestClient.get(url).body
      )

      # Return if nothing is found
      return 'No Results found' if data['result_type'] == 'no_results'

      # Return first definition
      string = data['list'].first['definition'].gsub(/\r|\n|\n\r/, ' ')
      string[0..450] + "... \u263A"
    rescue => e
      e.message
    end
  end
end

# AutoLoad
Bot.config.plugins.plugins.push Plugins::UrbanDictionary