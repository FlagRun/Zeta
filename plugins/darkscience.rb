require 'uri'
require 'net/http'
require 'ostruct'
require 'action_view'

module Plugins
  class DarkScience
    include Cinch::Plugin
    include ActionView::Helpers::DateHelper

    match /peek (.+)/, method: :peek
    match /finger (.+)/, method: :finger


    def peek(msg, channel)
      request = Hashie::Mash.new(request_channel(channel))

      return msg.reply("Finger → #{request.message}") if request.status == 500
      return msg.reply('Finger → Service Down') if request.status != 200
      return msg.reply('Peek → Channel Not Found') if request.data.channel.empty?

      msg.reply "Peek → #{request.data.channel.name} (#{request.data.channel.modes}) ~ " \
                "Users: #{request.data.channel.stats.current_users} (x̄ #{request.data.channel.stats.peak_users}) ~ " \
                "Last Topic set by #{request.data.channel.topic.author} @ #{Time.at(request.data.channel.topic.time).strftime("%D")}"
    end

    def finger(msg, nickname)
      request = request_user(nickname)

      return msg.reply('Finger → User Not Found') if request['data']['user'].empty?
      return msg.reply('Finger → Service Down') if request['status'] != 200

      user = request['data']['user']
      stats = request['data']['stats']
      away_msg = request['data']['user']['away_msg'] || "No Message"
      online_last = request['data']['user']['online_last'] || 0

      msg.reply "Finger → #{user['userstring']} ~ " \
                "#{user['identified'] ? 'Identified' : 'Not Identified'} ~ " \
                "Currently in #{stats['channel_count']} channels  ~ " \
                "Seen #{user['online'] ? 'Now' : time_ago_in_words(Time.at(online_last))+ " ago"}  ~ " \
                "Geo: #{user['country']} ~ " \
                "#{user['away'] ? 'Away: ' + away_msg : 'Available' } ~ " \
                "Client: #{user['version']} "
    end

    #############
    def servers_list
      url = 'http://v3.darchoods.net/api/irc/servers'
      request = JSON.parse(
          open(url).read
      )

    end

    def channels_list
      url = 'http://v3.darchoods.net/api/irc/channels'
      request = JSON.parse(
          open(url).read
      )

    end

    def request_channel(channel)
      # Request: My API (2) (http://dh.dev.daldridge.co.uk/api/irc/channel/view)

      #uri = URI.parse('http://dh.dev.daldridge.co.uk/api/irc/channel/view')
      uri = URI.parse('http://v3.darchoods.net/api/irc/channel/view')
      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 30
      request = Net::HTTP::Post.new(uri.request_uri)

      # Body

      request.set_form_data({
      	channel: channel
      })

      # Send synchronously

      response = http.request(request)
      JSON.parse response.body
    end

    def request_user(user)
      # uri = URI.parse('http://dh.dev.daldridge.co.uk/api/irc/user/view')
      uri = URI.parse('http://v3.darchoods.net/api/irc/user/view')
      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 30
      request = Net::HTTP::Post.new(uri.request_uri)

      # Body

      request.set_form_data({
      	username: user
      })

      # Send synchronously

      response = http.request(request)
      JSON.parse response.body
    end

    def request_channel_users(channel)
      # uri = URI.parse('http://dh.dev.daldridge.co.uk/api/irc/channel/users')
      uri = URI.parse('http://v3.darchoods.net/api/irc/channel/users')
      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 30
      request = Net::HTTP::Post.new(uri.request_uri)

      # Body

      request.set_form_data({
      	channel: channel
      })

      # Send synchronously

      response = http.request(request)
      JSON.parse response.body
    end

  end
end

# AutoLoad
Zeta.config.plugins.plugins.push Plugins::DarkScience



