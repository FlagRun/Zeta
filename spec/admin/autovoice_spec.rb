# frozen_string_literal: true

RSpec.describe Admin::AutoVoice do
  before { plugin(described_class).instance_variable_set(:@auto_voice_state, []) }

  def join(nick) = feed(":#{nick}!#{nick}@#{nick}.host JOIN #test")

  it 'voices identified users on join once enabled' do
    say 'opal', '.autovoice on'
    expect(replies).to eq(['AutoVoice is now enabled!'])

    join 'alice'
    join 'carol'
    expect(sent).to include('MODE #test +v alice')
    expect(sent).not_to include('MODE #test +v carol')
  end

  it 'can be disabled' do
    say 'opal', '.autovoice on'
    say 'opal', '.autovoice off'
    expect(replies.last).to eq('AutoVoice is now disabled!')
    join 'alice'
    expect(sent).not_to include('MODE #test +v alice')
  end

  it 'reports its status' do
    say 'opal', '.autovoice status'
    expect(replies).to eq(['AutoVoice is currently: Off'])
  end

  it 'is restricted to IRC operators' do
    say 'adam', '.autovoice on'
    expect(replies).to be_empty
  end
end
