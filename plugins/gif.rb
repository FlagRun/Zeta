require 'open-uri'
require 'nokogiri'

module Plugins
  class Gif
    include Cinch::Plugin
    include Cinch::Helpers

    # Author: blahed (https://github.com/blahed/gifbot)
    self.plugin_name = 'GIF'
    self.help = '?randomgif | ?gifme <query>'

    match "randomgif", method: :randomgif
    def randomgif(msg)
      return unless check_user(msg)
      return unless check_channel(msg)
      msg.reply "GB↦ #{random}" if random != nil
    end

    match /gifme (.+)/, method: :gifme
    def gifme(msg,query)
      return unless check_user(msg)
      return unless check_channel(msg)
      msg.reply "GB↦ #{search(query)}"
    end

    private

    def search(query)
      url = URI.encode "http://www.gifbin.com/search/#{query}/"
      doc = Nokogiri::HTML( open(url) )
      e = doc.css('.thumbs li').length
      return "No Results Found" if e == 0
      result = doc.css('.thumbs li')[rand(e)].css('a img').attribute('src').text.gsub(/tn_/, '')
      "http://www.gifbin.com#{result}"
    end

    def random
      url = URI.encode 'http://www.gifbin.com/random'
      doc = Nokogiri.HTML(open url)
      doc.css('div#gifcontainer a img').attribute('src').text
    end

  end
end

# AutoLoad
Zeta.config.plugins.plugins.push Plugins::Gif