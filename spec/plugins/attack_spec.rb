# frozen_string_literal: true

RSpec.describe Plugins::Attack do
  before do
    allow(plugin(described_class)).to receive(:load_locale).with('attack')
                                                            .and_return(['slaps <target> on behalf of <assailant> and <bot>'])
  end

  it 'attacks the named target' do
    say 'bob', '.attack carol'
    expect(actions_to).to eq(['slaps carol on behalf of bob and Zeta'])
  end

  it 'strips trailing whitespace from the target' do
    say 'bob', '.attack carol   '
    expect(actions_to).to eq(['slaps carol on behalf of bob and Zeta'])
  end

  it 'strips colour codes from the target' do
    say 'bob', ".attack \u000304carol and \u000304,12dave"
    expect(actions_to).to eq(['slaps carol and dave on behalf of bob and Zeta'])
  end

  it 'turns attacks on itself back on the attacker' do
    say 'bob', '.attack Zeta'
    expect(actions_to).to eq(['slaps bob on behalf of bob and Zeta'])
  end

  it 'turns "myself" into the attacker' do
    say 'bob', '.attack myself'
    expect(actions_to).to eq(['slaps bob on behalf of bob and Zeta'])
  end

  it 'only works in channels' do
    pm 'bob', '.attack carol'
    expect(sent.grep(/PRIVMSG/)).to be_empty
  end

  ['.attack', '.attack    '].each do |command|
    it "attacks a random channel member for #{command.inspect}" do
      say 'bob', command
      expect(actions_to.size).to eq(1)
      victim = actions_to.first[/\Aslaps (\S+) on behalf of bob and Zeta\z/, 1]
      expect(channel.users.keys.map(&:nick)).to include(victim)
    end
  end
end
