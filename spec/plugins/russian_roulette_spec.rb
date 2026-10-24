# frozen_string_literal: true

RSpec.describe Plugins::RussianRoulette do
  let(:rr) { plugin(described_class) }

  before do
    allow(rr).to receive(:sleep)
    rr.games.clear
  end

  def load_gun(turns:, bullet:)
    allow(Random).to receive(:new).and_return(double(rand: turns), double(rand: bullet))
  end

  it 'refuses to play without ops' do
    feed ':oscar!oscar@oscar.host MODE #test -o Zeta'
    say 'bob', '.rr'
    expect(replies).to eq(['I am sorry comrade, but I do not have pistol on me.'])
  end

  it 'only runs one game per channel' do
    rr.games << '#test'
    say 'bob', '.rr'
    expect(notices_to('bob')).to eq(['Sorry comrade, but there is already game going on.'])
  end

  it 'voices survivors' do
    load_gun(turns: 2, bullet: 5)
    say 'bob', '.rr'

    expect(actions_to).to eq([
                               'takes bob into the back room for a 2 turn game',
                               'pulls out her pistol',
                               'walks back into the room with bob',
                               'holsters the pistol.'
                             ])
    expect(notices_to('bob').size).to eq(2)
    expect(notices_to('bob')).to all(start_with('*click* '))
    expect(replies).to eq(['Looks like you get to live another day.'])
    expect(sent).to include('MODE #test +v bob')
    expect(rr.games).to be_empty
  end

  it 'kicks the unlucky' do
    load_gun(turns: 3, bullet: 2)
    say 'bob', '.rr'

    expect(notices_to('bob').last).to eq('*click*')
    expect(sent).to include('KICK #test bob :*BLAM*')
    expect(actions_to).to include('walks back into the room *Alone*', 'holsters the pistol.')
    expect(sent).not_to include('MODE #test +v bob')
    expect(rr.games).to be_empty
  end

  it 'ends the game early if the player leaves' do
    load_gun(turns: 3, bullet: 6)
    channel.remove_user(Bot.user_list.find('bob'))
    say 'bob', '.rr'
    expect(replies).to eq(['Oh vell, it vas fun vhile it lasted.'])
    expect(rr.games).to be_empty
  end
end
