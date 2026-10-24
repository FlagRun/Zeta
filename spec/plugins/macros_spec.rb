# frozen_string_literal: true

RSpec.describe Plugins::Macros do
  it 'loads macros from the locale' do
    expect(plugin(described_class).macros).to include('dnf', 'punch')
  end

  it 'loads the locale when the plugin is created' do
    fresh = described_class.new(Bot)
    fresh.unregister
    expect(fresh.macros).to include('dnf' => 'Duke Nukem Forever came out. Your argument is invalid.')
  end

  it 'sends a simple macro' do
    say 'bob', '.dnf'
    expect(replies).to eq(['Duke Nukem Forever came out. Your argument is invalid.'])
  end

  it 'substitutes [in] and [self]' do
    say 'bob', '.hi5 carol'
    expect(replies).to eq(['carol (from bob): http://www.ihighfive.com/'])
  end

  it 'sends random action macros' do
    say 'bob', '.punch carol'
    expect(actions_to.size).to eq(1)
    expect(actions_to.first).to include('carol')
  end

  it 'applies transforms' do
    say 'bob', '.alart fire'
    expect(replies.first).to include('FIRE')
  end

  it 'falls back to the default text without input' do
    say 'bob', '.alart'
    expect(replies.last).to include('ALART')
  end

  it 'picks a random channel member without input or default' do
    say 'bob', '.bod'
    nick = replies.last[/\A(\S+) should go eat/, 1]
    expect(channel.users.keys.map(&:nick)).to include(nick)
  end

  it 'supports [bot] and [channel] tokens' do
    plugin(described_class).macros['where'] = 'I am [bot] in [channel], cap/[self]'
    say 'bob', '.where'
    expect(replies).to eq(['I am Zeta in #test, BOB'])
  ensure
    plugin(described_class).macros.delete('where')
  end

  describe 'hash macros' do
    let(:macros) { plugin(described_class).macros }

    after { macros.delete('multi') }

    it 'sends every line in order unless the type is random' do
      macros['multi'] = { 'lines' => ['one [self]', 'two', 'three'] }
      say 'bob', '.multi'
      expect(replies).to eq(['one bob', 'two', 'three'])
    end

    it 'sends every line as an action' do
      macros['multi'] = { 'sent_as' => 'action', 'lines' => ['waves at [in]', 'bows'] }
      say 'bob', '.multi carol'
      expect(actions_to).to eq(['waves at carol', 'bows'])
      expect(replies).to be_empty
    end

    it 'waits before each line when a sleep is configured' do
      log = []
      allow(plugin(described_class)).to receive(:sleep) { |secs| log << "sleep #{secs}" }
      allow(Bot.irc).to receive(:send).and_wrap_original { |orig, line| log << line; orig.call(line) }
      macros['multi'] = { 'sleep' => 2, 'lines' => %w[ready set] }
      say 'bob', '.multi'
      expect(log).to eq(['sleep 2', 'PRIVMSG #test :ready', 'sleep 2', 'PRIVMSG #test :set'])
    end
  end

  it 'ignores unknown macros' do
    say 'bob', '.definitelynotamacro'
    expect(replies).to be_empty
  end

  it 'only works in channels' do
    pm 'bob', '.dnf'
    expect(sent.grep(/PRIVMSG/)).to be_empty
  end

  it 'reloads macros in private for admins of the secure channel' do
    IrcHarness.sync_channel!('#secure', '@Zeta &adam bob')
    pm 'adam', '.reload'
    expect(notices_to('adam')).to eq(['Macros have been reloaded.'])
  end

  it 'reloads macros for IRC operators' do
    pm 'opal', '.reload'
    expect(notices_to('opal')).to eq(['Macros have been reloaded.'])
  end

  it 'reads the macros back from the locale on reload' do
    macros = plugin(described_class)
    original = macros.macros
    macros.instance_variable_set(:@macros, {})
    say 'bob', '.dnf'
    expect(replies).to be_empty

    pm 'opal', '.reload'
    say 'bob', '.dnf'
    expect(replies).to eq(['Duke Nukem Forever came out. Your argument is invalid.'])
  ensure
    macros.instance_variable_set(:@macros, original) if macros.macros.empty?
  end

  it 'does not reload macros for regular users' do
    pm 'bob', '.reload'
    expect(notices_to('bob')).to be_empty
  end
end
