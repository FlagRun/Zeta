# frozen_string_literal: true

RSpec.describe Admin::Blacklister do
  let(:cache) { File.join(Dir.home, '.zeta', 'cache', 'blacklist.rb') }

  it 'blacklists channels and saves' do
    say 'opal', '.bl channel #spam'
    expect(replies).to eq(['#spam is now on the BlackList'])
    expect(Blacklist.channels).to eq(['#spam'])
    expect(File).to exist(cache)
  end

  it 'blacklists urls' do
    say 'opal', '.bl url spam.example'
    expect(replies).to eq(['spam.example is now on the BlackList'])
    expect(Blacklist.urls).to eq(['spam.example'])
  end

  it 'does not add duplicate channels' do
    Blacklist.channels << '#spam'
    say 'opal', '.bl channel #spam'
    expect(replies).to eq(['#spam is already on BlackList'])
    expect(Blacklist.channels).to eq(['#spam'])
  end

  it 'does not add duplicate urls' do
    Blacklist.urls << 'spam.example'
    say 'opal', '.bl url spam.example'
    expect(replies).to eq(['spam.example is already on BlackList'])
    expect(Blacklist.urls).to eq(['spam.example'])
  end

  it 'blacklists hostmasks' do
    say 'opal', '.bl mask *!*@bad.host'
    expect(replies).to eq(['*!*@bad.host is now on the BlackList'])
    expect(Blacklist.masks).to eq(['*!*@bad.host'])

    say 'opal', '.bl mask *!*@bad.host'
    expect(replies.last).to eq('*!*@bad.host is already on BlackList')
    expect(Blacklist.masks).to eq(['*!*@bad.host'])
  end

  it 'restores the defaults from Config.options' do
    save_blacklist
    say 'opal', '.bl defaults'
    expect(replies).to eq(['Default Blacklist Loaded'])
    expect(Blacklist.urls).to eq(['bad.example'])
    expect(Blacklist.users).to eq(['spammer'])
    expect(Blacklist.channels).to eq(['#quiet'])
  end

  it 'syncs to disk' do
    Blacklist.urls << 'x.example'
    say 'opal', '.bl sync'
    expect(actions_to).to eq(['Blacklist is now synced!'])
    expect(File.open(cache) { |f| Marshal.load(f) }.urls).to eq(['x.example'])
  end

  it 'is restricted to IRC operators' do
    say 'adam', '.bl channel #spam'
    expect(Blacklist.channels).to be_empty
  end
end
