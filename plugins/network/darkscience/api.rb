require 'uri'
require 'net/http'
require 'ostruct'
require 'action_view'

module Plugins::DarkScience
  class API
    include Cinch::Plugin
    include Cinch::Helpers
    include ActionView::Helpers::DateHelper

    self.plugin_name = 'DarkScience API'
    self.help = '?finger <nick>, ?peek <#channel>, ?stats <nick>, ?quote, ?addquote <quote>, ?quote <id>'

    match /peek (.+)/, method: :peek

    def peek(msg, channel)
      return unless check_user(msg)
      return unless check_channel(msg)
      chan = channel || msg.user.channel

      # JSON Request
      begin
        data = JSON.parse(
            RestClient.post(
                'https://darchoods.net/api/irc/channel/view',
                {
                  auth_token: Zsec.darkscience,
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

    match /finger (.+)/, method: :finger

    def finger(msg, nickname)
      return unless check_user(msg)
      return unless check_channel(msg)
      nick = nickname || msg.user.nick

      # JSON request
      begin
        data = JSON.parse(
            RestClient.post(
                'https://darchoods.net/api/irc/user/view',
                {
                  auth_token: Zsec.darkscience,
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
                "Client: #{user['version']} "
    end

    match /stats (.+)/, method: :stats

    def stats(msg, nickname)
      return unless check_user(msg)
      return unless check_channel(msg)
      nick = nickname || msg.user.nick

      # JSON request
      begin
        data = JSON.parse(
            RestClient.post(
                'https://darchoods.net/api/irc/user/view',
                {
                  auth_token: Zsec.darkscience,
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

    match /addquote (.+)/i,  method: :addquote

    def addquote(m, quote)
      return unless check_user(m)
      return unless check_channel(m)
      begin
        request = JSON.parse(
            RestClient.post(
                'https://darchoods.net/api/qdb/create',
                {
                  auth_token: Zsec.darkscience,
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

    match /quote (.+)/i,     method: :quote

    def quote(m, search)
      return unless check_user(m)
      return unless check_channel(m)
      begin
        request = JSON.parse(
            RestClient.post(
                'https://darchoods.net/api/qdb/search/byId',
                {
                  auth_token: Zsec.darkscience,
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

    match "quote",           method: :randomquote

    def randomquote(m)
      return unless check_user(m)
      return unless check_channel(m)
      begin
        request = JSON.parse(
            RestClient.post(
                'https://darchoods.net/api/qdb/random',
                { auth_token: Zsec.darkscience,
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
Zeta.config.plugins.plugins.push Plugins::DarkScience::API



