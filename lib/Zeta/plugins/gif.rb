require 'open-uri'
require 'nokogiri'
require 'json'

module Plugins
  class Gif
    include Cinch::Plugin
    include Cinch::Helpers
    enable_acl

    # Author: blahed (https://github.com/blahed/gifbot)
    self.plugin_name = 'GIF'
    self.help = '?randomgif | ?rgif | ?gifme <query>'

    def initialize(*args)
      super
      @imgurray = []
      @last_update = Time
    end

    match 'randomgif', method: :imgif
    match 'rgif', method: :imgif
    match 'imgif', method: :imgif
    def imgif(msg)
      msg.reply "IMGUR↦ #{imgur}"
    end

    match /gifme (.+)/, method: :gifme
    def gifme(msg,query)
      msg.reply "GB↦ #{search(query)}"
    end

    private

    def search(query)
      parser = URI::Parser.new
      url = parser.escape "http://www.gifbin.com/search/#{query}/"

      doc = Nokogiri::HTML( RestClient.get(url).body )
      e = doc.css('.thumbs li').length
      return "No Results Found" if e == 0
      result = doc.css('.thumbs li')[rand(e)].css('a img').attribute('src').text.gsub(/tn_/, '')
      "http://www.gifbin.com#{result}"
    end

    def gifbin
      parser = URI::Parser.new

      url = parser.escape 'http://www.gifbin.com/random'
      doc = Nokogiri.HTML(RestClient.get(url).body)
      doc.css('div#gifcontainer a img').attribute('src').text
    end

    def imgur
      # Cache results for 1 hour
      if @imgurray.empty? || @last_update >= (Time.now + 3600)
        parser = URI::Parser.new

        url = parser.escape('http://reddit.com/r/gifs.json')
        doc = JSON.load(RestClient.get(url).body)

        doc['data']['children'].each_with_index do |post, index|
          if doc['data']['children'][index]['data']['url'].to_s =~ /imgur/
            @imgurray << doc['data']['children'][index]['data']['url'].to_s
          end
        end
        @last_update = Time.now
        @imgurray.sample
      else
        @imgurray.sample
      end

    end

  end
end

# AutoLoad
Bot.config.plugins.plugins.push Plugins::Gif
