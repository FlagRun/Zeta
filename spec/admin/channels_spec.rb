# frozen_string_literal: true

RSpec.describe Admin::Channels do
  it 'joins channels' do
    say 'opal', '.join #a, #b'
    expect(sent).to include('JOIN #a', 'JOIN #b')
  end

  it 'parts the current channel' do
    say 'opal', '.part'
    expect(sent).to include('PART #test :opal')
  end

  it 'parts another channel with a reason' do
    say 'opal', '.part #other see ya'
    expect(sent).to include('PART #other :see ya')
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
