# frozen_string_literal: true

RSpec.describe Plugins::Gif do
  # Expire the hour-long imgur cache left behind by earlier examples
  before { plugin(described_class).instance_variable_set(:@last_update, Time.at(0)) }

  it 'searches gifbin' do
    stub_request(:get, 'http://www.gifbin.com/search/cats/')
      .to_return(body: '<ul class="thumbs"><li><a href="/1"><img src="/tn_123.gif"></a></li></ul>')
    say 'bob', '.gifme cats'
    expect(replies).to eq(['GB↦ http://www.gifbin.com/123.gif'])
  end

  it 'reports empty searches' do
    stub_request(:get, 'http://www.gifbin.com/search/nothing/').to_return(body: '<ul class="thumbs"></ul>')
    say 'bob', '.gifme nothing'
    expect(replies).to eq(['GB↦ No Results Found'])
  end

  it 'picks a random imgur gif from r/gifs and caches the list' do
    stub = stub_request(:get, 'http://reddit.com/r/gifs.json').to_return(body: {
      data: { children: [
        { data: { url: 'https://i.imgur.com/abc.gif' } },
        { data: { url: 'https://gfycat.com/whatever' } }
      ] }
    }.to_json)

    say 'bob', '.rgif'
    say 'bob', '.randomgif'

    expect(replies).to eq(['IMGUR↦ https://i.imgur.com/abc.gif'] * 2)
    expect(stub).to have_been_requested.once
  end

  it 'refreshes the imgur list after an hour' do
    stub = stub_request(:get, 'http://reddit.com/r/gifs.json').to_return(
      { body: { data: { children: [{ data: { url: 'https://i.imgur.com/old.gif' } }] } }.to_json },
      { body: { data: { children: [{ data: { url: 'https://i.imgur.com/new.gif' } }] } }.to_json }
    )
    say 'bob', '.rgif'
    travel_to(Time.now + 3601) { say 'bob', '.rgif' }

    expect(replies).to eq(['IMGUR↦ https://i.imgur.com/old.gif', 'IMGUR↦ https://i.imgur.com/new.gif'])
    expect(stub).to have_been_requested.twice
  end
  it 'drops stale gifs when the refreshed list has none' do
    stub_request(:get, 'http://reddit.com/r/gifs.json').to_return(
      { body: { data: { children: [{ data: { url: 'https://i.imgur.com/old.gif' } }] } }.to_json },
      { body: { data: { children: [{ data: { url: 'https://v.redd.it/xyz' } }] } }.to_json }
    )
    say 'bob', '.imgif'
    travel_to(Time.now + 3601) { say 'bob', '.imgif' }

    expect(replies).to eq(['IMGUR↦ https://i.imgur.com/old.gif', 'IMGUR↦ '])
  end

  it 'is listed in .help' do
    say 'bob', '.help gif'
    expect(notices_to('bob')).to eq(["Help for \u0002GIF\u000f:", '?randomgif | ?rgif | ?gifme <query>'])
  end
end
