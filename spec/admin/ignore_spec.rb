# frozen_string_literal: true

RSpec.describe Admin::Ignore do
  it 'ignores users in the channel' do
    say 'opal', '.ignore bob'
    expect(actions_to).to eq(['is now ignoring bob'])
    expect(Blacklist.users).to eq(['bob'])

    say 'bob', '.hello'
    expect(replies).to be_empty
  end

  it 'refuses to ignore yourself' do
    say 'opal', '.ignore opal'
    expect(replies).to eq(["You can't ignore yourself"])
  end

  it 'only ignores users present in the channel' do
    say 'opal', '.ignore ghost'
    expect(replies).to eq(["ghost isn't currently in channel"])
  end

  it 'reports users who are already ignored' do
    Blacklist.users << 'bob'
    say 'opal', '.ignore bob'
    expect(replies).to eq(['bob is already being ignored'])
    expect(Blacklist.users).to eq(['bob'])
  end

  it 'unignores users' do
    Blacklist.users << 'bob'
    say 'opal', '.unignore bob'
    expect(actions_to).to eq(['is no longer ignoring bob'])
    expect(Blacklist.users).to be_empty

    say 'opal', '.unignore bob'
    expect(replies).to eq(["bob isn't on the ignore list"])
  end

  it 'lists ignored users' do
    Blacklist.users.push('bob', 'carol')
    say 'opal', '.ignorelist'
    expect(replies).to eq(['Currently, ignored users are: bob, carol'])
  end

  it 'disables and re-enables the current channel' do
    say 'opal', '.disable'
    expect(actions_to).to eq(['has disabled #test buffer'])
    expect(Blacklist.channels).to eq(['#test'])

    say 'bob', '.hello'
    expect(replies).to be_empty

    say 'opal', '.disable'
    expect(replies).to eq(['Channel is currently disabled'])

    say 'opal', '.enable'
    expect(actions_to.last).to eq('has enabled #test buffer')
    say 'bob', '.hello'
    expect(replies.last).to eq('Hello, bob!')
  end

  it 'persists every change to the blacklist cache' do
    file = File.join(Dir.home, '.zeta', 'cache', 'blacklist.rb')
    saved = -> { File.open(file) { |f| Marshal.load(f) } }

    say 'opal', '.ignore bob'
    expect(saved.call.users).to eq(['bob'])
    say 'opal', '.unignore bob'
    expect(saved.call.users).to be_empty
    say 'opal', '.disable #other'
    expect(saved.call.channels).to eq(['#other'])
    say 'opal', '.enable #other'
    expect(saved.call.channels).to be_empty
  end

  it 'disables and enables other channels' do
    say 'opal', '.disable #other'
    expect(actions_to).to eq(['has disabled #other buffer'])
    expect(Blacklist.channels).to eq(['#other'])
    say 'opal', '.enable #other'
    expect(actions_to.last).to eq('has enabled #other buffer')
    expect(Blacklist.channels).to be_empty
    say 'opal', '.enable #other'
    expect(replies).to eq(['Channel is currently enabled'])
  end

  it 'is available to ops of the secure channel' do
    IrcHarness.sync_channel!('#secure', '@Zeta @oscar bob')
    say 'oscar', '.ignore bob'
    expect(Blacklist.users).to eq(['bob'])
  end

  it 'is not available to ops of other channels' do
    %w[oscar bob].each { |nick| say nick, '.ignore carol' }
    expect(Blacklist.users).to be_empty
  end
end
