# frozen_string_literal: true

RSpec.describe Plugins::RussianRoulette do
  let(:rr) { plugin(described_class) }

  before do
    @sleeps = []
    allow(rr).to receive(:sleep) { |secs| @sleeps << [secs, sent.size] }
    rr.games.clear
  end

  def load_gun(turns:, bullet:)
    guns = [turns, bullet].map do |n|
      instance_double(Random).tap { |gun| allow(gun).to receive(:rand).with(1..6).and_return(n) }
    end
    allow(Random).to receive(:new).and_return(*guns)
  end

  # Everything the bot sent, interleaved with its pauses. Random phrases are
  # replaced by PHRASE after checking they are genuine, unused ones.
  def timeline
    used = []
    events = sent.map do |line|
      phrase = line[/\ANOTICE bob :\*click\* (.+)\z/, 1]
      next line unless phrase

      expect(described_class::PHRASES).to include(phrase)
      expect(used).not_to include(phrase)
      used << phrase
      'NOTICE bob :*click* PHRASE'
    end
    @sleeps.reverse_each { |secs, at| events.insert(at, "sleep #{secs}") }
    events.grep_v(/\AWHOIS /)
  end

  def act_line(text)
    "PRIVMSG #test :\u0001ACTION #{text}\u0001"
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

  it 'paces a survived game and voices the survivor' do
    load_gun(turns: 2, bullet: 5)
    say 'bob', '.rr'

    expect(timeline).to eq([
                             act_line('takes bob into the back room for a 2 turn game'),
                             act_line('pulls out her pistol'),
                             'sleep 5',
                             'NOTICE bob :*click* PHRASE',
                             'sleep 5',
                             'NOTICE bob :*click* PHRASE',
                             'sleep 5',
                             act_line('walks back into the room with bob'),
                             'PRIVMSG #test :Looks like you get to live another day.',
                             'MODE #test +v bob',
                             'sleep 1',
                             'sleep 1',
                             act_line('holsters the pistol.')
                           ])
  end

  it 'paces a lost game and kicks the player after the fatal click' do
    load_gun(turns: 3, bullet: 2)
    say 'bob', '.rr'

    expect(timeline).to eq([
                             act_line('takes bob into the back room for a 3 turn game'),
                             act_line('pulls out her pistol'),
                             'sleep 5',
                             'NOTICE bob :*click* PHRASE',
                             'sleep 5',
                             'NOTICE bob :*click*',
                             'sleep 5',
                             'KICK #test bob :*BLAM*',
                             act_line('walks back into the room *Alone*'),
                             'sleep 1',
                             act_line('holsters the pistol.')
                           ])
  end

  it 'turns away other players while a game is running' do
    load_gun(turns: 1, bullet: 6)
    allow(rr).to receive(:sleep) do |secs|
      @sleeps << [secs, sent.size]
      # carol tries to join in while the gun is still out
      if @sleeps.size == 1
        Bot.irc.parse(':carol!carol@carol.host PRIVMSG #test :.rr')
        deadline = Time.now + 5
        sleep 0.01 until sent.any? { |l| l.match?(/\A(NOTICE carol|PRIVMSG #test :\u0001ACTION takes carol)/) } || Time.now > deadline
      end
    end
    say 'bob', '.rr'
    IrcHarness.wait_for_handlers

    expect(notices_to('carol')).to eq(['Sorry comrade, but there is already game going on.'])
    expect(actions_to.grep(/back room/)).to eq(['takes bob into the back room for a 1 turn game'])
    expect(rr.games).to be_empty
  end

  it 'ends the game early if the player leaves' do
    load_gun(turns: 3, bullet: 6)
    channel.remove_user(Bot.user_list.find('bob'))
    say 'bob', '.rr'
    expect(replies).to eq(['Oh vell, it vas fun vhile it lasted.'])
    expect(timeline).to eq([
                             act_line('takes bob into the back room for a 3 turn game'),
                             act_line('pulls out her pistol'),
                             'sleep 5',
                             'PRIVMSG #test :Oh vell, it vas fun vhile it lasted.',
                             'sleep 1',
                             act_line('holsters the pistol.')
                           ])
    expect(rr.games).to be_empty
  end
end
