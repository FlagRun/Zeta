require 'open-uri'
require 'nokogiri'
require 'json'

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
      msg.reply "GB↦ #{gifbin}" if gifbin != nil
    end

    match "imgif", method: :imgif
    def imgif(msg)
        return unless check_user(msg)
        return unless check_channel(msg)
        msg.reply "IMGUR↦ #{imgur}" if imgur != nil
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

    def gifbin
      url = URI.encode 'http://www.gifbin.com/random'
      doc = Nokogiri.HTML(open url)
      doc.css('div#gifcontainer a img').attribute('src').text
    end

    def imgur
        # TODO: add caching support
        url = URI.encode('http://reddit.com/r/gifs.json')
        doc = JSON.load(open(url))
        imgurray = []
        doc['data']['children'].each_with_index do |post,index|
          if doc['data']['children'][index]['data']['url'].to_s =~ /imgur/
             imgurray << doc['data']['children'][index]['data']['url'].to_s
          end
        end
      imgurray.sample
    end
  end
end

# AutoLoad
Zeta.config.plugins.plugins.push Plugins::Gif
