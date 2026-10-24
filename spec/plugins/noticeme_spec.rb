# frozen_string_literal: true

RSpec.describe Plugins::Noticeme do
  it 'refreshes the user and notices them' do
    say 'bob', '.noticeme'
    expect(sent).to include('WHOIS bob bob')
    expect(notices_to('bob')).to eq(['Refreshing bob'])
  end

  it 're-WHOISes the user on every request, even once they are synced' do
    say 'bob', '.noticeme'
    say 'bob', '.noticeme'
    expect(sent).to eq(['WHOIS bob bob', 'NOTICE bob :Refreshing bob', 'WHOIS bob bob', 'NOTICE bob :Refreshing bob'])
  end

  it 'shows its help under its plugin name' do
    say 'bob', '.help notice me!'
    expect(notices_to('bob')).to eq(["Help for \x02Notice ME!\x0F:", 'Make sure zeta can see me!'])
  end
end
