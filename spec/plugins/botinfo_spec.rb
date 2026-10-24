# frozen_string_literal: true

RSpec.describe Plugins::BotInfo do
  it 'lists plugins in private' do
    pm 'bob', 'list plugins'
    notices = notices_to('bob')
    expect(notices.first).to eq("All #{Bot.plugins.size} currently loaded plugins for Zeta:")
    expect(notices.last).to eq('To view help for a plugin, use `/msg Zeta help <plugin name>`.')
  end

  it 'shows plugin help in private' do
    pm 'bob', 'help 8ball'
    expect(notices_to('bob').first).to eq("Help for \x028ball\x0F:")
  end

  it 'reports unknown plugins' do
    pm 'bob', 'help nope'
    expect(notices_to('bob')).to eq(['Help for "nope" could not be found.'])
  end

  it 'does not respond in channels' do
    say 'bob', 'list plugins'
    expect(notices_to('bob')).to be_empty
  end

  it 'notices bot information' do
    pm 'bob', 'info'
    expect(notices_to('bob')).to eq([
                                      "Hello I'm Zeta.",
                                      'I am currently trolling 9 users in 1 channels with an uptime of ' \
                                      "#{notices_to('bob')[1][/uptime of (.*)\z/, 1]}",
                                      "My master is Liothen and he has plugged me with #{Bot.plugins.size - 10} plugins"
                                    ])
  end
end
