require 'uri'
require 'net/http'
require 'ostruct'
require 'action_view'

module Plugins
  class DarkScience
    include Cinch::Plugin
    include Cinch::Helpers
    include ActionView::Helpers::DateHelper

    enable_acl(:nobody)

    self.plugin_name = 'DarkScience API'
    self.help = '?finger <nick>, ?peek <#channel>, ?stats <nick>, ?quote, ?addquote <quote>, ?quote <id>'

    # Triggers
    match /peek (.+)/, method: :peek
    match /finger (.+)/, method: :finger
    match /stats (.+)/, method: :stats
    match /addquote (.+)/i, method: :addquote
    match /quote (.+)/i, method: :quote
    match 'quote', method: :randomquote


    # Methods
    #########
    def peek(msg, channel)
      chan = channel || msg.user.channel

      # JSON Request
      begin
        RestClient.proxy = ENV['http_proxy']
        data = JSON.parse(
            RestClient.post(
                'https://darchoods.net/api/irc/channel/view',
                {
                  auth_token: Config.secrets[:darkscience],
                  channel: chan,
                }
            )
        )
      rescue RestClient::Unauthorized
        msg.action_reply "isn't currently authorized to do that"
      end

      # Turn JSON into an object
      request = Hashie::Mash.new(data)

      # Error Code replies
      return msg.reply("Peek → #{request.message}") if request.status_code == 500
      return msg.reply('Peek → Service Down') if request.status_code != 200
      return msg.reply('Peek → Channel Not Found') if request.data.channel.empty?

      msg.reply "Peek → #{request.data.channel.name} (#{request.data.channel.modes}) ~ " \
                "Users: #{request.data.channel.stats.current_users} (#{request.data.channel.stats.peak_users}x̄) ~ " \
                "Last Topic set by #{request.data.channel.topic.author} @ #{Time.at(request.data.channel.topic.time).strftime("%D")}"
    end


    def finger(msg, nickname)
      nick = nickname || msg.user.nick

      # JSON request
      begin
        RestClient.proxy = ENV['http_proxy']
        data = JSON.parse(
            RestClient.post(
                'https://darchoods.net/api/irc/user/view',
                {
                  auth_token: Config.secrets[:darkscience],
                  username: nick,
                }
            )
        )
      rescue RestClient::Unauthorized
        msg.action_reply "isn't currently authorized to do that"
      end

      # Turn JSON into an object
      # request = Hashie::Mash.new(data)


      # Error code replies
      return msg.reply('Finger → User Not Found') if data['data']['user'].empty?
      return msg.reply('Finger → Service Down') if data['status_code'] != 200

      user = data['data']['user']
      stats = data['data']['stats']
      away_msg = data['data']['user']['away_msg'] || "No Message"
      online_last = data['data']['user']['online_last'] || 0

      msg.reply "Finger → #{user['userstring']} ~ " \
                "#{user['identified'] ? 'Identified' : 'Not Identified'} ~ " \
                "Currently in #{stats['channel_count']} channels  ~ " \
                "Seen #{user['online'] ? 'Now' : time_ago_in_words(Time.at(online_last))+ " ago"}  ~ " \
                "Geo: #{user['country']} ~ " \
                "#{user['away'] ? 'Away: ' + away_msg : 'Available' } ~ " \
                "Client: #{user['version']} ~ "
    end


    def stats(msg, nickname)
      nick = nickname || msg.user.nick

      # JSON request
      begin
        data = JSON.parse(
            RestClient.post(
                'https://darchoods.net/api/irc/user/view',
                {
                  auth_token: Config.secrets[:darkscience],
                  username: nick,
                }
            )
        )
      rescue RestClient::Unauthorized
        msg.action_reply "isn't currently authorized to do that"
      end

      # Turn JSON into an object
      # request = Hashie::Mash.new(data)


      # Error code replies
      return msg.reply('Statistics → User Not Found') if data['data']['user'].empty?
      return msg.reply('Statistics → Service Down') if data['status_code'] != 200

      user = data['data']['user']
      stats = data['data']['stats']

      msg.reply "Statistics → #{user['nick']} ~ " \
                "Currently in #{stats['channel_count']} ~ " \
                "Owner of #{stats['mode_counts']['q']} channels ~ " \
                "Admin of #{stats['mode_counts']['a']} channels ~ " \
                "Operator(halfop) of #{stats['mode_counts']['o']}(#{stats['mode_counts']['h']}) channels ~ " \
                "and finally voiced in #{stats['mode_counts']['v']} channels"

    end

    def addquote(m, quote)
      begin
        request = JSON.parse(
            RestClient.post(
                'https://darchoods.net/api/qdb/create',
                {
                  auth_token: Config.secrets[:darkscience],
                  channel: m.channel,
                  author: m.user,
                  quote: quote
                }
            )
        )
        quote = Hashie::Mash.new(request)

        m.reply "Quote ##{quote.data.quote.quote_id} added by #{m.user}!"
      rescue RestClient::Unauthorized
        m.action_reply "isn't currently authorized to do that"
      rescue
        m.reply 'QDB is unavailable right now'
      end
    end

    def quote(m, search)
      begin
        request = JSON.parse(
            RestClient.post(
                'https://darchoods.net/api/qdb/search/byId',
                {
                  auth_token: Config.secrets[:darkscience],
                  channel: m.channel,
                  quote_id: search
                }
            )
        )
        quote = Hashie::Mash.new(request)

        return m.reply 'There is no quote by that ID' unless quote.data.quote

        m.reply "QDB##{quote.data.quote.quote_id}: #{quote.data.quote.content}"
      rescue RestClient::Unauthorized
        m.action_reply "isn't currently authorized to do that"
      rescue
        m.reply "QDB is unavailable right now"
      end

    end

    def randomquote(m)
      begin
        request = JSON.parse(
            RestClient.post(
                'https://darchoods.net/api/qdb/random',
                { auth_token: Config.secrets[:darkscience],
                  channel: m.channel
                }
            )
        )
        quote = Hashie::Mash.new(request)

        m.reply "QDB##{quote.data.quote.quote_id}: #{quote.data.quote.content}"
      rescue RestClient::Unauthorized
        m.action_reply "isn't currently authorized to do that"
      rescue
        m.reply "QDB is unavailable right now"
      end

    end


  end
end

# AutoLoad
Bot.config.plugins.plugins.push Plugins::DarkScience