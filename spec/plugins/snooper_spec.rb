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
    expect(replies).to eq(["\x0306IMGUR\x0F [\x0303SAFE\x0F] ∴ [\x0308image/png\x0F] 640x480 ∴ Views: 42 ∴ A cat " \
                           '∴ Posted about 2 hours ago'])
  end

  it 'flags NSFW imgur images and handles missing titles' do
    stub_request(:get, 'https://api.imgur.com/3/image/Xyz9')
      .to_return(body: { data: { nsfw: true, type: 'image/gif', width: 1, height: 2, views: 0,
                                 title: nil, datetime: Time.now.to_i - (3 * 86_400) } }.to_json)
    say 'bob', 'https://imgur.com/gallery/Xyz9'
    expect(replies).to eq(["\x0306IMGUR\x0F [\x0304NSFW\x0F] ∴ [\x0308image/gif\x0F] 1x2 ∴ Views: 0 ∴ No Title " \
                           '∴ Posted 3 days ago'])
  end

  it 'treats imgur links without an image id as ordinary pages' do
    stub_request(:get, 'http://imgur.com/').to_return(body: '<html><head><title>Imgur</title></head></html>',
                                                       headers: { 'Content-Type' => 'text/html' })
    say 'bob', 'imgur.com'
    expect(replies).to eq(['‡ Imgur'])
    expect(a_request(:get, %r{api\.imgur\.com})).not_to have_been_made
  end

  it 'describes YouTube videos' do
    allow(VideoInfo).to receive(:new).with('https://www.youtube.com/watch?v=abc')
                                     .and_return(instance_double(VideoInfo, title: 'Never Gonna', duration: 213))
    say 'bob', 'https://www.youtube.com/watch?v=abc'
    expect(replies).to eq(["\x0304YouTube \x0F∴ Never Gonna ( \x030300:03:33\x0F )"])
  end

  it 'hands the Google API key to VideoInfo for YouTube lookups' do
    allow(VideoInfo).to receive(:new).and_return(instance_double(VideoInfo, title: 'T', duration: 1))
    VideoInfo.provider_api_keys = {}
    say 'bob', 'https://youtu.be/abc'
    expect(VideoInfo.provider_api_keys).to eq(youtube: 'google-key')
  end

  it 'apologises for broken links', :allow_errors do
    stub_request(:get, 'http://example.com/missing').to_return(status: 404)
    say 'bob', 'http://example.com/missing'
    expect(replies).to eq(['I am unable to load that URL'])
    expect(IrcHarness.error_log.lines.map { _1.chomp.split(' !! ', 2).last }).to eq([
      '[Plugins::Snooper] Mechanize::ResponseCodeError: 404 => Net::HTTPNotFound for http://example.com/missing -- unhandled response',
      '[Plugins::Snooper] [404] bob - http://example.com/missing'
    ])
  end

  it 'gives up on slow sites', :allow_errors do
    stub_request(:get, 'http://example.com/slow').to_timeout
    say 'bob', 'http://example.com/slow'
    expect(replies).to eq(['URL was forced Timed out'])
    expect(IrcHarness.error_log.lines.map { _1.chomp.split(' !! ', 2).last }).to eq(['[Plugins::Snooper] [408] bob - http://example.com/slow'])
  end

  it 'fetches pages with a short-lived, size-capped agent under a 12s hard timeout' do
    settings = nil
    allow(Mechanize).to receive(:start).and_wrap_original do |original, &block|
      original.call do |agent|
        block.call(agent).tap do
          settings = { max_history: agent.max_history, read_timeout: agent.read_timeout,
                       max_file_buffer: agent.max_file_buffer }
        end
      end
    end
    allow(Timeout).to receive(:timeout).and_call_original
    stub_request(:get, 'http://example.com/page').to_return(body: '<title>Hi</title>', headers: { 'Content-Type' => 'text/html' })
    say 'bob', 'http://example.com/page'
    expect(replies).to eq(['‡ Hi'])
    expect(settings).to eq(max_history: 1, read_timeout: 4, max_file_buffer: 2_097_152)
    expect(Timeout).to have_received(:timeout).with(12).once
  end

  it 'percent-escapes unsafe characters before fetching' do
    stub_request(:get, 'http://example.com/100%25').to_return(body: '<title>Percent</title>', headers: { 'Content-Type' => 'text/html' })
    say 'bob', 'example.com/100%'
    expect(replies).to eq(['‡ Percent'])
  end

  describe 'link detection' do
    def page(title)
      { body: "<title>#{title}</title>", headers: { 'Content-Type' => 'text/html' } }
    end

    it 'recognises two-letter TLDs and short domain names' do
      stub_request(:get, 'http://go.io/doc').to_return(page('Go'))
      say 'bob', 'see go.io/doc'
      expect(replies).to eq(['‡ Go'])
    end

    it 'recognises IPv4 addresses with single digit octets' do
      stub_request(:get, 'http://1.2.3.4/page').to_return(page('IP'))
      say 'bob', 'http://1.2.3.4/page'
      expect(replies).to eq(['‡ IP'])
    end

    it 'reads at most three digits per IPv4 octet' do
      stub_request(:get, 'http://1.2.3.456/').to_return(page('Cut'))
      say 'bob', 'http://1.2.3.4567/page'
      expect(replies).to eq(['‡ Cut'])
    end

    it 'ignores numbers that are not dotted quads' do
      stub_request(:any, /.*/).to_return(page('Nope'))
      say 'bob', 'call 1234.5.6.7 now'
      expect(replies).to be_empty
    end

    it 'ignores domain labels longer than 63 characters' do
      stub_request(:any, /.*/).to_return(page('Nope'))
      say 'bob', "#{'a' * 64}.com"
      expect(replies).to be_empty
    end

    it 'reads long TLDs in full' do
      stub_request(:get, 'http://example.science/page').to_return(page('Science'))
      say 'bob', 'example.science/page'
      expect(replies).to eq(['‡ Science'])
    end

    it 'keeps ports of one to five digits' do
      stub_request(:get, 'http://example.com:8/page').to_return(page('Port'))
      stub_request(:get, 'http://example.com:12345/page').to_return(page('Long port'))
      stub_request(:get, 'http://example.com:12345/').to_return(page('Truncated port'))
      say 'bob', 'example.com:8/page'
      say 'bob', 'example.com:12345/page'
      say 'bob', 'example.com:123456/page'
      expect(replies).to eq(['‡ Port', '‡ Long port', '‡ Truncated port'])
    end
  end

  it 'only snoops in channels' do
    pm 'bob', 'http://example.com/page'
    expect(sent.grep(/PRIVMSG/)).to be_empty
  end
end
