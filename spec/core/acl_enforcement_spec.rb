# frozen_string_literal: true

# Every plugin calls `enable_acl`, which registers a pre-hook that must keep
# ignored users and blacklisted channels from reaching the plugin's handlers.
# The handler itself is replaced with a spy so only the ACL gate is under test.
RSpec.describe 'ACL enforcement in plugins' do
  CASES = [
    [Plugins::Wikipedia, :execute, '.wiki ruby'],
    [Plugins::Fnord, :execute, '.fnord'],
    [Plugins::Rainbow, :execute_rainbow, '.rainbow hello'],
    [Plugins::DNSBlacklist, :dnsbl_lookup, '.dnsbl 127.0.0.2'],
    [Plugins::BotHelp, :execute_list, '.help'],
    [Plugins::Snooper, :execute, 'look at https://example.org/page'],
    [Plugins::Seen, :execute, '.seen carol'],
    [Plugins::BotInfo, :execute, 'info', :private],
    [Plugins::Macros, :execute_macro, '.emergency'],
    [Plugins::PDFinfo, :execute, 'https://example.org/doc.pdf'],
    [Plugins::RussianRoulette, :russian, '.rr'],
    [Plugins::Movie, :find_movie, '.movie Alien'],
    [Plugins::Attack, :execute, '.attack carol'],
    [Plugins::Weather, :weather, '.w London'],
    [Plugins::DBZ, :randomquote, 'it is Over 9000'],
    [Plugins::Gif, :imgif, '.rgif'],
    [Plugins::Eightball, :execute, '.8ball will it work?'],
    [Plugins::Wolfram, :calculate, '.calc 1+1'],
    [Plugins::Silly, :halloween, '.halloween'],
    [Plugins::DarkScience, :peek, '.peek bob'],
    [Plugins::Fml, :execute, '.fml'],
    [Plugins::UrbanDictionary, :query, '.ud ruby']
  ].freeze

  def send_command(text, scope)
    scope == :private ? pm('bob', text) : say('bob', text)
  end

  CASES.each do |klass, handler, text, scope|
    describe klass do
      let(:calls) { [] }

      before do
        calls = self.calls
        without_partial_double_verification { allow(plugin(klass)).to receive(handler) { calls << handler } }
      end

      it "runs ##{handler} for regular users" do
        send_command(text, scope)
        expect(calls).to eq([handler])
      end

      it 'ignores users on the ignore list' do
        Blacklist.users << 'bob'
        send_command(text, scope)
        expect(calls).to be_empty
      end

      next if scope == :private

      it 'stays silent in blacklisted channels' do
        Blacklist.channels << IrcHarness::CHANNEL
        send_command(text, scope)
        expect(calls).to be_empty
      end
    end
  end

  describe Admin::AutoVoice do
    it 'does not let the oper override work in a blacklisted #services' do
      IrcHarness.sync_channel!('#services', '@Zeta opal')
      Blacklist.channels << '#services'
      say 'opal', '.autovoice on', channel: '#services'
      expect(messages_to('#services')).to be_empty

      Blacklist.channels.clear
      say 'opal', '.autovoice on', channel: '#services'
      expect(messages_to('#services')).to eq(['AutoVoice is now enabled!'])
    end
  end

  describe Admin::Plugins do
    it 'requires admin status in the secure channel, not the current one' do
      say 'adam', '.plugin load Hello'
      expect(replies).to be_empty

      IrcHarness.sync_channel!('#secure', '@Zeta &adam')
      say 'adam', '.plugin load Hello'
      expect(replies).to eq(['Hello is already loaded.'])
    end
  end
end
