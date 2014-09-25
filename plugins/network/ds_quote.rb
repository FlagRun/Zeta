require 'uri'
require 'net/http'
require 'ostruct'
require 'action_view'

module Plugins::DarkScience
  class Quote
    include Cinch::Plugin
    include Cinch::Helpers
    include ActionView::Helpers::DateHelper

    self.plugin_name = 'DarkScience Quote'
    self.help = '?quote for random quote, ?quote <id> for specific, ?addquote <quote> to add'

    match /addquote (.+)/i,  method: :addquote
    match /quote (.+)/i,     method: :quote
    match "quote",           method: :randomquote

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
        m.reply "QDB is unavailable right now"
      end
    end

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
Zeta.config.plugins.plugins.push Plugins::DarkScience::Quote
