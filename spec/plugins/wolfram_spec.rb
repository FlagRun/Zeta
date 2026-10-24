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
  it 'notices three-line results to the user' do
    stub_request(:get, api).with(query: hash_including(input: 'roots of x^3-x')).to_return(body: result('x^3-x = 0', "x = -1\nx = 0\nx = 1"))
    say 'bob', '.calc roots of x^3-x'
    expect(replies).to be_empty
    expect(notices_to('bob')).to eq(['# Wolfram Results #', ' x^3-x = 0', ' x = -1', 'x = 0', 'x = 1'])
  end

  it 'answers two-line results in the channel' do
    stub_request(:get, api).with(query: hash_including({})).to_return(body: result('sqrt(4)', "2\n-2"))
    say 'bob', '.calc sqrt(4)'
    expect(replies).to eq(["sqrt(4) = 2", '-2'])
  end

  it 'reports an empty input interpretation' do
    stub_request(:get, api).with(query: hash_including({})).to_return(body: result('', '42'))
    say 'bob', '.calc nothing'
    expect(replies).to eq(['Unable to get a results'])
  end

  it 'is listed in .help' do
    say 'bob', '.help wolfram alpha plugin'
    expect(notices_to('bob')).to eq(["Help for \u0002Wolfram Alpha plugin\u000f:", 'WIP'])
  end
end
