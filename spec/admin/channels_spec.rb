# frozen_string_literal: true

RSpec.describe Admin::Channels do
  # Admin plugins announce what they did through a custom :admin event.
  def capture_admin_events
    events = []
    handler = Bot.on(:admin) { |_m, text, target| events << [text, target.to_s] }
    yield events
  ensure
    Bot.handlers.unregister(handler)
  end

  it 'joins channels and announces each attempt' do
    capture_admin_events do |events|
      say 'opal', '.join #a, #b key'
      expect(sent).to include('JOIN #a', 'JOIN #b key')
      expect(events).to contain_exactly(['Attempt to join #a by opal...', '#test'], ['Attempt to join #b by opal...', '#test'])
    end
  end

  it 'parts the current channel' do
    capture_admin_events do |events|
      say 'opal', '.part'
      expect(sent).to include('PART #test :opal')
      expect(events).to eq([['Parted #test - opal', '#test']])
    end
  end

  it 'parts another channel with a reason' do
    capture_admin_events do |events|
      say 'opal', '.part #other see ya'
      expect(sent).to include('PART #other :see ya')
      expect(events).to eq([['Parted #other - see ya', '#test']])
    end
  end

  it 'is available to ops of the secure channel' do
    IrcHarness.sync_channel!('#secure', '@Zeta @oscar bob')
    say 'oscar', '.join #a'
    expect(sent).to include('JOIN #a')
  end

  it 'is not available to ops of other channels' do
    say 'oscar', '.join #a'
    expect(sent).not_to include('JOIN #a')
  end
end
