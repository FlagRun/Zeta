require 'action_view'
module Plugins
  class Seen
    include ActionView::Helpers::DateHelper
    class SeenStruct < Struct.new(:who, :where, :time); end

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
      return if m.channel == '#services'
      @users[m.user.nick] = SeenStruct.new(m.user, m.channel, Time.now)
    end

    def execute(m, nick)
      nick.rstrip!
      if nick == @bot.nick
        m.reply 'You are a Stupid human!'
      elsif nick == m.user.nick
        m.reply "Unfortunately, I see an idiot by the name of #{m.user.nick}"
      elsif @users.key?(nick) && (@users[nick].where == m.channel)
        time_ago = time_ago_in_words(Time.at(@users[nick].time))
        m.reply "Seen ∴ \x0304#{@users[nick].who}\x0F was last seen talking in here about \x02#{time_ago}\x0F ago."
      else
        m.reply "I haven't seen #{nick} say anything yet!"
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
        begin
          File.open(File.join(Dir.home, '.zeta', 'cache', 'seen.rb')) do |file|
            return Marshal.load(file)
          end
        rescue
          return Hash.new
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