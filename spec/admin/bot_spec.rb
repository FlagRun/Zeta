# frozen_string_literal: true

RSpec.describe Admin::Bot do
  it 'changes the nick' do
    say 'opal', '.set nick Zeta2'
    expect(sent).to include('NICK Zeta2')
  ensure
    Bot.config.nick = 'Zeta'
  end

  it 'quits with a reason' do
    allow(plugin(described_class)).to receive(:sleep)
    say 'opal', '.die maintenance'
    expect(sent).to include('QUIT :maintenance')
  ensure
    Bot.instance_variable_set(:@quitting, false)
  end

  it 'sets and unsets user modes' do
    say 'opal', '.set mode +xB'
    expect(sent).to include('MODE Zeta +x', 'MODE Zeta +B')
    expect(Bot.modes).to eq(%w[x B])

    say 'opal', '.set mode -B+i'
    expect(sent).to include('MODE Zeta -B', 'MODE Zeta +i')
    expect(Bot.modes).to eq(%w[x i])
  ensure
    Bot.instance_variable_set(:@modes, [])
  end

  it 'is restricted to IRC operators' do
    say 'adam', '.set nick Evil'
    expect(sent).not_to include('NICK Evil')
  end
end
