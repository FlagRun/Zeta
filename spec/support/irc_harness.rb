# frozen_string_literal: true

# Drives the real Cinch bot without a network connection: raw IRC lines are
# fed through Cinch's parser and everything the bot would write to the socket
# is recorded instead.
module IrcHarness
  CHANNEL = '#test'
  # ~ owner, & admin, @ op, % halfop, + voice
  NAMES = '@Zeta ~olly &adam @oscar %hal +alice bob carol opal'
  OPERS = %w[opal].freeze
  ACCOUNTS = { 'alice' => 'alice', 'opal' => 'opal' }.freeze
  HANDLER_TIMEOUT = 15

  class << self
    attr_reader :error_io

    def boot!
      @sent = []
      @lock = Mutex.new
      @error_io = StringIO.new

      Bot.loggers.clear
      Bot.loggers << Cinch::Logger::FormattedLogger.new(@error_io, level: :error)

      Bot.plugins.register_plugins(Bot.config.plugins.plugins)
      irc = Bot.irc
      irc.setup
      harness = self
      irc.define_singleton_method(:send) { |line| harness.record(line) }
      Bot.set_nick(Bot.config.nick)

      # Cinch only tracks channel owners (+q list) on IRCds it recognises.
      irc.parse ':irc.test 002 Zeta :Your host is irc.test, running version InspIRCd-3'
      irc.parse ':irc.test 005 Zeta PREFIX=(qaohv)~&@%+ CHANTYPES=# :are supported by this server'
      irc.parse ":Zeta!zeta@bot.host JOIN #{CHANNEL}"
      sync_channel!
      wait_for_handlers

      @config_snapshot = Marshal.dump(Config.to_h)
      @blacklist_file = File.join(Dir.home, '.zeta', 'cache', 'blacklist.rb')
    end

    def reset!
      wait_for_handlers
      Marshal.load(@config_snapshot).each { |key, value| Config[key] = value }
      %i[channels users plugins urls masks].each { |field| Blacklist[field] = [] }
      FileUtils.rm_f(@blacklist_file)
      Bot.channel_list.each { |c| c.clear_users unless c.name == CHANNEL }
      sync_channel!
      wait_for_handlers
      @lock.synchronize { @sent.clear }
      @error_io.truncate(0)
      @error_io.rewind
    end

    def sync_channel!(name = CHANNEL, names = NAMES)
      Bot.irc.parse ":irc.test 353 Zeta = #{name} :#{names}"
      Bot.irc.parse ":irc.test 366 Zeta #{name} :End of /NAMES list."
      # Answer the owner list query (MODE #chan +q) Cinch sends on join
      names.split.grep(/\A~/).each { |n| Bot.irc.parse ":irc.test 386 Zeta #{name} #{n.delete_prefix('~')}" }
      Bot.irc.parse ":irc.test 387 Zeta #{name} :End of channel owner list"
    end

    def record(line)
      @lock.synchronize { @sent << line }
      answer_whois(Regexp.last_match(1)) if line =~ /\AWHOIS (\S+)/
      true # Admin::Oper checks the return value of irc.send
    end

    def sent
      @lock.synchronize { @sent.dup }
    end

    def error_log
      @error_io.string
    end

    def feed(line)
      Bot.irc.parse(line)
      wait_for_handlers
    end

    def wait_for_handlers
      deadline = Time.now + HANDLER_TIMEOUT
      loop do
        threads = Bot.handlers.flat_map { |h| h.thread_group.list }
        break if threads.empty?
        raise "handlers still running after #{HANDLER_TIMEOUT}s" if Time.now > deadline

        threads.each { |t| t.join(0.5) }
      end
    end

    private

    # Cinch blocks on WHOIS (User#refresh, #oper, #authed?) until the server
    # answers, so reply asynchronously like a real ircd would.
    def answer_whois(nick)
      Thread.new do
        irc = Bot.irc
        irc.parse ":irc.test 311 Zeta #{nick} #{nick} #{nick}.host * :#{nick}"
        irc.parse ":irc.test 313 Zeta #{nick} :is an IRC Operator" if OPERS.include?(nick)
        irc.parse ":irc.test 330 Zeta #{nick} #{ACCOUNTS[nick]} :is logged in as" if ACCOUNTS.key?(nick)
        irc.parse ":irc.test 318 Zeta #{nick} :End of /WHOIS list."
      end
    end
  end

  module Helpers
    def feed(line)
      IrcHarness.feed(line)
    end

    def say(nick, text, channel: IrcHarness::CHANNEL)
      feed(":#{nick}!#{nick}@#{nick}.host PRIVMSG #{channel} :#{text}")
    end

    def pm(nick, text)
      feed(":#{nick}!#{nick}@#{nick}.host PRIVMSG Zeta :#{text}")
    end

    def act(nick, text, channel: IrcHarness::CHANNEL)
      say(nick, "\u0001ACTION #{text}\u0001", channel: channel)
    end

    def sent
      IrcHarness.sent
    end

    # PRIVMSG bodies (excluding CTCP ACTIONs) sent to target
    def messages_to(target = IrcHarness::CHANNEL)
      privmsgs(target).reject { |m| m.start_with?("\u0001ACTION") }
    end

    def actions_to(target = IrcHarness::CHANNEL)
      privmsgs(target).grep(/\A\u0001ACTION /).map { |m| m.delete_prefix("\u0001ACTION ").delete_suffix("\u0001") }
    end

    def notices_to(target)
      sent.filter_map { |l| l[/\ANOTICE #{Regexp.escape(target)} :(.*)\z/m, 1] }
    end

    def replies
      messages_to
    end

    def plugin(klass)
      Bot.plugins.find { |p| p.instance_of?(klass) }
    end

    def channel
      Bot.channel_list.find(IrcHarness::CHANNEL)
    end

    private

    def privmsgs(target)
      sent.filter_map { |l| l[/\APRIVMSG #{Regexp.escape(target)} :(.*)\z/m, 1] }
    end
  end
end
