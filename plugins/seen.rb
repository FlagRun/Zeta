require 'action_view'
module Plugins
  class Seen
    class SeenStruct < Struct.new(:who, :where, :what, :time)
      include ActionView::Helpers::DateHelper
      def to_s
        # "[#{time.asctime}] #{who} was seen in #{where} last saying #{what}"
        time_ago = time_ago_in_words(Time.at(time))
        "[ \x1F#{where.to_s.upcase}\x0F ] \x0304#{who}\x0F: \"\x0303#{what[0..300]}\x0F\" \x02#{time_ago}\x0F ago"
      end
    end

    include Cinch::Plugin
    include Cinch::Helpers

    enable_acl()

    listen_to :channel
    match /seen (.+)/

    def initialize(*args)
      super
      @users = {}
    end

    def listen(m)
      @users[m.user.nick] = SeenStruct.new(m.user, m.channel, m.message, Time.now)
    end

    def execute(m, nick)
      nick.rstrip!
      if nick == @bot.nick
        m.reply 'You are a Stupid human!'
      elsif nick == m.user.nick
        m.reply "Unfortunately, I see an idiot by the name of #{m.user.nick}"
      elsif @users.key?(nick)
        m.reply @users[nick].to_s
      else
        m.reply "I haven't seen #{nick}"
      end
    end
  end
end

# AutoLoad
Zeta.config.plugins.plugins.push Plugins::Seen