# frozen_string_literal: true

RSpec.describe Plugins::Snooper, :snooper do
  it 'replies with the page title' do
    stub_request(:get, 'http://example.com/page')
      .to_return(body: "<html><head><title>\n  Example\nPage</title></head></html>", headers: { 'Content-Type' => 'text/html' })
    say 'bob', 'look at example.com/page'
    expect(replies).to eq(['‡ Example Page'])
  end

  it 'stays quiet for pages without a title' do
    stub_request(:get, 'https://example.com/').to_return(body: '<html></html>', headers: { 'Content-Type' => 'text/html' })
    say 'bob', 'https://example.com/'
    expect(replies).to be_empty
  end

  it 'skips blacklisted hosts' do
    Blacklist.urls << 'example.com'
    say 'bob', 'http://example.com/page'
    expect(replies).to be_empty
  end

  it 'describes imgur images' do
    stub_request(:get, 'https://api.imgur.com/3/image/AbC123')
      .with(headers: { 'Authorization' => 'Client-ID imgur-id' })
      .to_return(body: { data: { nsfw: false, type: 'image/png', width: 640, height: 480, views: 42,
                                 title: 'A cat', datetime: Time.now.to_i - 7200 } }.to_json)
    say 'bob', 'https://i.imgur.com/AbC123.png'
    expect(replies.size).to eq(1)
    expect(replies.first).to include('IMGUR', 'SAFE', 'image/png', '640x480', 'Views: 42', 'A cat', 'Posted about 2 hours ago')
  end

  it 'describes YouTube videos' do
    allow(VideoInfo).to receive(:new).with('https://www.youtube.com/watch?v=abc')
                                     .and_return(instance_double(VideoInfo, title: 'Never Gonna', duration: 213))
    say 'bob', 'https://www.youtube.com/watch?v=abc'
    expect(replies.size).to eq(1)
    expect(replies.first).to include('YouTube', '∴ Never Gonna', '00:03:33')
  end

  it 'apologises for broken links', :allow_errors do
    stub_request(:get, 'http://example.com/missing').to_return(status: 404)
    say 'bob', 'http://example.com/missing'
    expect(replies).to eq(['I am unable to load that URL'])
    expect(IrcHarness.error_log).to include('Mechanize::ResponseCodeError', '[404] bob - http://example.com/missing')
  end

  it 'gives up on slow sites', :allow_errors do
    stub_request(:get, 'http://example.com/slow').to_timeout
    say 'bob', 'http://example.com/slow'
    expect(replies).to eq(['URL was forced Timed out'])
  end

  it 'only snoops in channels' do
    pm 'bob', 'http://example.com/page'
    expect(sent.grep(/PRIVMSG/)).to be_empty
  end
end
