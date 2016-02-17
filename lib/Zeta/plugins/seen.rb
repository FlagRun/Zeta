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

    enable_acl(:nobody)

    listen_to :channel
    match /seen (.+)/
    match /sync/, method: :sync

    def initialize(*args)
      super
      @users = load_seen
    end

    def finalize
      save_seen()
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

    def sync(m)
      save_seen()
    end

    def save_seen
      File.open(File.join(Dir.home, '.zeta', 'cache', 'seen.rb'), 'w+') do |file|
        Marshal.dump(@users, file)
      end

    end

    def load_seen
      if File.exists?(File.join(Dir.home, '.zeta', 'cache', 'seen.rb'))
        File.open(File.join(Dir.home, '.zeta', 'cache', 'seen.rb')) do |file|
          return Marshal.load(file)
        end
      else
        return Hash.new
      end
    end

    def clear_seen
      @users = {}
      File.delete(File.join(Dir.home, '.zeta', 'cache', 'seen.rb'))
    end
  end
end

# AutoLoad
Bot.config.plugins.plugins.push Plugins::Seen