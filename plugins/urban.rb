require 'cinch'
require 'open-uri'
require 'nokogiri'

module Plugins
  class UrbanDictionary
    include Cinch::Plugin
    include Cinch::Helpers

    enable_acl

    set(
        plugin_name: 'UrbanDictionary',
        help: "Urban Dictionary -- Grabs a term from urbandictionary.com.\nUsage: `?urban <term>`; `?wotd`; `!?woty`"
    )

    match /urban (.*)/, method: :query
    match /ud (.*)/,    method: :query
    match /wotd/,       method: :wotd
    match "ud",         method: :wotd

    def query(m, query)
      m.reply "UD↦ #{search(query)}"
    end


    def wotd(m)
      url = URI.encode "http://www.urbandictionary.com/"
      doc = Nokogiri.HTML(
          # RestClient.get(url)
          open(url)
      )
      word = doc.at_css('.word').text.strip[0..40]
      meaning = doc.at_css('.meaning').text.strip[0..450] + "... \u263A"
      m.reply "UD↦ #{word} -- #{meaning}"
    end

    private
    def search(query)
      url = URI.encode "http://api.urbandictionary.com/v0/define?term=#{query}"
      # Nokogiri.HTML(open url).at_css('.meaning').text.strip[0..500]

      # Load API data
      data = JSON.parse(
          #RestClient.get(url)
          open(url).read
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
Zeta.config.plugins.plugins.push Plugins::UrbanDictionary