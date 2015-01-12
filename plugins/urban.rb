require 'cinch'
require 'open-uri'
require 'nokogiri'

module Plugins
  class UrbanDictionary
    include Cinch::Plugin
    include Cinch::Helpers

    set(
        plugin_name: 'UrbanDictionary',
        help: "Urban Dictionary -- Grabs a term from urbandictionary.com.\nUsage: `?urban <term>`; `?wotd`; `!?woty`"
    )

    match /urban (.*)/, method: :query
    match /ud (.*)/,    method: :query
    match /wotd/,       method: :wotd
    match "ud",         method: :wotd

    def query(m, query)
      return unless check_user(m)
      return unless check_channel(m)
      m.user.notice "UD↦ #{search(query)}"
    end


    def wotd(m)
      return unless check_user(m)
      return unless check_channel(m)
      url = URI.encode "http://www.urbandictionary.com/"
      doc = Nokogiri.HTML(open url)
      word = doc.at_css('.word').text.strip[0..500]
      meaning = doc.at_css('.meaning').text.strip[0..500]
      m.user.notice "UD↦ #{word} -- #{meaning}"
    end

    private
    def search(query)
      url = URI.encode "http://api.urbandictionary.com/v0/define?term=#{query}"
      # Nokogiri.HTML(open url).at_css('.meaning').text.strip[0..500]

      # Load API data
      data = JSON.parse(
          open(url).read
      )

      # Return if nothing is found
      return 'No Results found' if data['result_type'] == 'no_results'

      # Return first definition
      data['list'].first['definition'].strip[0..500].gsub(/\r\n/, ' ')
    rescue => e
      e.message
    end
  end
end

# AutoLoad
Zeta.config.plugins.plugins.push Plugins::UrbanDictionary