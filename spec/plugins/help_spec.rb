# frozen_string_literal: true

RSpec.describe Plugins::BotHelp do
  it 'lists all loaded plugins' do
    say 'bob', '.help'
    expect(notices_to('bob').first).to eq("All #{Bot.plugins.size} currently loaded plugins for Zeta:")
    expect(notices_to('bob').join(' ')).to include('Rainbow', '8ball', 'Weather')
  end

  it 'shows help for a plugin (case-insensitive)' do
    say 'bob', '.help RAINBOW'
    expect(notices_to('bob')).to eq([
                                      "Help for \x02Rainbow\x0F:",
                                      'Rainbowificates your text.',
                                      'Usage: `?rainbow [text]`.',
                                      'Usage: `?eyerape [text]`.'
                                    ])
  end

  it 'reports unknown plugins' do
    say 'bob', '.help nope'
    expect(notices_to('bob')).to eq(['Help for "nope" could not be found.'])
  end
end
