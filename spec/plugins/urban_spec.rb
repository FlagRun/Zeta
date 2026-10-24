# frozen_string_literal: true

RSpec.describe Plugins::UrbanDictionary do
  let(:api) { 'http://api.urbandictionary.com/v0/define' }

  it 'defines a term' do
    stub_request(:get, api).with(query: { term: 'ruby' })
                           .to_return(body: { result_type: 'exact', list: [{ definition: "A shiny\ngem" }] }.to_json)
    say 'bob', '.ud ruby'
    expect(replies).to eq(["UD↦ A shiny gem... \u263A"])
  end

  it 'escapes multi word terms' do
    stub = stub_request(:get, "#{api}?term=hello%20world")
           .to_return(body: { result_type: 'exact', list: [{ definition: 'hi' }] }.to_json)
    say 'bob', '.urban hello world'
    expect(stub).to have_been_requested
  end

  it 'truncates long definitions' do
    stub_request(:get, api).with(query: hash_including({}))
                           .to_return(body: { result_type: 'exact', list: [{ definition: 'x' * 1000 }] }.to_json)
    say 'bob', '.ud long'
    expect(replies.first).to eq("UD↦ #{'x' * 451}... \u263A")
  end

  it 'reports missing definitions' do
    stub_request(:get, api).with(query: hash_including({})).to_return(body: { result_type: 'no_results', list: [] }.to_json)
    say 'bob', '.ud zzzz'
    expect(replies).to eq(['UD↦ No Results found'])
  end

  it 'reports HTTP errors' do
    stub_request(:get, api).with(query: hash_including({})).to_return(status: 500)
    say 'bob', '.ud ruby'
    expect(replies).to eq(['UD↦ 500 Internal Server Error'])
  end

  it 'shows the word of the day' do
    stub_request(:get, 'http://www.urbandictionary.com/')
      .to_return(body: '<div class="word"> yeet </div><div class="meaning">to throw</div>')
    say 'bob', '.wotd'
    expect(replies).to eq(["UD↦ yeet -- to throw... \u263A"])
  end

  it 'shows the word of the day for a bare .ud' do
    stub_request(:get, 'http://www.urbandictionary.com/')
      .to_return(body: '<div class="word">yeet</div><div class="meaning">to throw</div>')
    say 'bob', '.ud'
    expect(replies).to eq(["UD↦ yeet -- to throw... \u263A"])
  end
end
