# frozen_string_literal: true

RSpec.describe Plugins::Wolfram do
  let(:api) { 'http://api.wolframalpha.com/v2/query' }

  def result(input, output)
    <<~XML
      <queryresult>
        <pod><subpod><plaintext>#{input}</plaintext></subpod></pod>
        <pod><subpod><plaintext>#{output}</plaintext></subpod></pod>
      </queryresult>
    XML
  end

  it 'answers short queries in the channel' do
    stub_request(:get, api)
      .with(query: { input: '2+2', appid: 'wolfram-key', primary: 'true', format: 'plaintext' })
      .to_return(body: result('2+2', '4'))
    say 'bob', '.calc 2+2'
    expect(replies).to eq(['2+2 = 4'])
  end

  it 'notices multi-line results to the user' do
    stub_request(:get, api).with(query: hash_including({})).to_return(body: result('primes', "2\n3\n5\n7"))
    say 'bob', '.wolfram primes'
    expect(replies).to be_empty
    expect(notices_to('bob')).to eq(['# Wolfram Results #', ' primes', ' 2', '3', '5', '7'])
  end

  it 'handles results without plaintext' do
    stub_request(:get, api).with(query: hash_including({}))
                           .to_return(body: '<queryresult><pod><subpod></subpod></pod><pod><subpod></subpod></pod></queryresult>')
    say 'bob', '.calc ???'
    expect(replies).to eq(['Unable to get a results'])
  end

  it 'handles failures' do
    stub_request(:get, api).with(query: hash_including({})).to_return(status: 500)
    say 'bob', '.wolframalpha anything'
    expect(replies).to eq(['Unable to get a results'])
  end
end
