# frozen_string_literal: true

RSpec.describe Plugins::Noticeme do
  it 'refreshes the user and notices them' do
    say 'bob', '.noticeme'
    expect(sent).to include('WHOIS bob bob')
    expect(notices_to('bob')).to eq(['Refreshing bob'])
  end
end
