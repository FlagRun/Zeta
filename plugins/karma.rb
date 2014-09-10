# written by mpapis/cinch-yaml-karma

module Plugins
  class Karma
    include Cinch::Plugin
    include Cinch::Helpers

    def initialize(*args)
      super
      if File.exist?($root_path + '/data/karma.yml')
        @karma = YAML.load_file($root_path + '/data/karma.yml')
      else
        @karma = {}
      end
    end

    match(/karmas/, method: :karmas)

    def karmas(m)
      return unless check_user(m)
      return unless check_channel(m)
      m.reply "Most Karma: #{@karma.sort_by { |k, v| -v }.map { |k, v| "#{k}: #{v}" }*", "}."
    end

    match(/karma (\S+)/, method: :karma)

    def karma(m, nick)
      return unless check_user(m)
      return unless check_channel(m)
      if @karma[nick]
        m.reply "Karma for #{nick}: #{@karma[nick]}."
      else
        m.reply "#{nick} has no karma."
      end
    end

    match /cheater (\S+)/, method: :cheater
    def cheater(m, nick)
      return unless check_user(m, :operator)
      return unless check_channel(m)
      if @karma[nick]
        @karma.delete(nick)
        update_store
        m.action_reply "Hates cheaters... #{nick} now has 0 karma"
      else
        m.action_reply "Searches for said cheater"
      end

    end


    match(/(\S+) ([-+]1)/, use_prefix: false, use_suffix: false, method: :change)
    match(/(\S+) ?([-+]{2})$/, use_prefix: false, use_suffix: false, method: :change)

    def change(m, nick, karma)
      return unless check_user(m)
      return unless check_channel(m)
      if m.channel.has_user?(nick)
        change_nick(m, nick, karma)
      elsif %w( , : ).include?(nick[-1]) && m.channel.has_user?(nick.slice(0..-2))
        nick.slice!(-1)
        change_nick(m, nick, karma)
      elsif config[:warn_no_user_message]
        m.reply config[:warn_no_user_message] % nick
      end
    end

    private
    def update_store
      synchronize(:update) do
        File.open($root_path +'/data/karma.yml', 'w') do |fh|
          YAML.dump(@karma, fh)
        end
      end
    end

    def change_nick(m, nick, karma)
      if nick == m.user.nick
        m.reply "You can't give Karma to yourself..."
      elsif nick == bot.nick
        m.reply "You can't give karma to me..."
      else
        karma.sub!(/([+-]){2}/, '\11')
        @karma[nick] ||= 0
        @karma[nick] += karma.to_i
        @karma.delete(nick) if @karma[nick] == 0
        m.reply "#{m.user.nick}(#{@karma[m.user.nick]}) gave #{karma} karma to #{nick}(#{@karma[nick]})."
        update_store
      end
    end
  end
end

# AutoLoad
Zeta.config.plugins.plugins.push Plugins::Karma