# frozen_string_literal: true

RSpec.describe Plugins::Fml do
  it 'fetches a random FML' do
    stub_request(:get, 'http://www.fmylife.com/random')
      .to_return(body: '<html><body><article> Today, I wrote specs for a bot. FML </article></body></html>')
    say 'bob', '.fml'
    expect(replies).to eq(['bob: Today, I wrote specs for a bot. FML'])
  end

  it 'reports errors' do
    stub_request(:get, 'http://www.fmylife.com/random').to_return(status: 503)
    say 'bob', '.fml'
    expect(replies).to eq(['bob: 503 Service Unavailable'])
  end
end
