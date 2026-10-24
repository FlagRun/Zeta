# frozen_string_literal: true

RSpec.describe 'Blacklist' do
  let(:file) { File.join(Dir.home, '.zeta', 'cache', 'blacklist.rb') }

  it 'starts out empty' do
    expect(Blacklist.to_h.values).to all(be_empty)
  end

  it 'persists to ~/.zeta/cache with save_blacklist' do
    Blacklist.channels << '#nope'
    Blacklist.urls << 'spam.example'
    save_blacklist

    restored = File.open(file) { |f| Marshal.load(f) }
    expect(restored.channels).to eq(['#nope'])
    expect(restored.urls).to eq(['spam.example'])
  end

  it 'empties every list and removes the cache file with clear_blacklist' do
    Blacklist.users << 'troll'
    save_blacklist

    clear_blacklist

    expect(Blacklist.to_h.values).to all(eq([]))
    expect(File).not_to exist(file)
  end
end
