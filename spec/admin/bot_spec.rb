# frozen_string_literal: true

RSpec.describe Admin::Bot do
  # Admin plugins announce what they did through a custom :admin event.
  def capture_admin_events
    events = []
    handler = Bot.on(:admin) { |_m, text, target| events << [text, target.to_s] }
    yield events
  ensure
    Bot.handlers.unregister(handler)
  end

  it 'changes the nick and announces it' do
    capture_admin_events do |events|
      say 'opal', '.set nick Zeta2'
      expect(sent).to include('NICK Zeta2')
      expect(events).to eq([['My nick got changed from Zeta to Zeta2 by opal', '#test']])
    end
  ensure
    Bot.config.nick = 'Zeta'
  end

  it 'quits with a reason after announcing the shutdown and waiting two seconds' do
    capture_admin_events do |events|
      quit_sent_before_sleep = nil
      allow(plugin(described_class)).to receive(:sleep) { quit_sent_before_sleep = sent.grep(/\AQUIT/).any? }
      say 'opal', '.die maintenance'
      expect(plugin(described_class)).to have_received(:sleep).with(2).once
      expect(quit_sent_before_sleep).to be(false)
      expect(sent.grep(/\AQUIT/)).to eq(['QUIT :maintenance'])
      expect(events).to eq([['I am being shut down NOW! - Reason: maintenance', '#test']])
    end
  ensure
    Bot.instance_variable_set(:@quitting, false)
  end

  it 'uses the requesting nick as the quit reason when none is given' do
    capture_admin_events do |events|
      allow(plugin(described_class)).to receive(:sleep)
      say 'opal', '.die'
      expect(sent.grep(/\AQUIT/)).to eq(['QUIT :opal'])
      expect(events).to eq([['I am being shut down NOW! - Reason: opal', '#test']])
    end
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
