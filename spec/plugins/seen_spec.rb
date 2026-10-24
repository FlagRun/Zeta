# frozen_string_literal: true

RSpec.describe Plugins::Seen do
  before { plugin(described_class).instance_variable_set(:@users, {}) }

  it 'reports when a user last spoke in the channel' do
    say 'alice', 'hello there'
    say 'bob', '.seen alice'
    expect(replies.last).to eq("Seen ∴ \x0304alice\x0F was last seen talking in here about \x02less than a minute\x0F ago.")
  end

  it 'uses a human readable duration' do
    travel_to(Time.now - 3 * 3600) { say 'alice', 'hello' }
    say 'bob', '.seen alice'
    expect(replies.last).to include("about \x02about 3 hours\x0F ago")
  end

  it 'only reports activity in the same channel' do
    say 'alice', 'psst', channel: '#elsewhere'
    say 'bob', '.seen alice'
    expect(replies).to eq(["I haven't seen alice say anything yet!"])
  end

  it 'mocks users looking for themselves' do
    say 'bob', '.seen bob'
    expect(replies).to eq(['Unfortunately, I see an idiot by the name of bob'])
  end

  it 'insults users looking for the bot' do
    say 'bob', '.seen Zeta'
    expect(replies).to eq(['You are a Stupid human!'])
  end

  it 'saves the seen database with .sync and loads it back' do
    say 'alice', 'hello'
    say 'bob', '.sync'

    seen = plugin(described_class)
    restored = seen.load_seen
    expect(restored['alice']).to have_attributes(who: 'alice', where: '#test')

    seen.instance_variable_set(:@users, restored)
    say 'bob', '.seen alice'
    expect(replies.last).to start_with("Seen ∴ \x0304alice\x0F was last seen")
  end
end
