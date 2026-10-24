# frozen_string_literal: true

RSpec.describe Plugins::DarkScience do
  let(:qdb) { 'https://quotes.example.org/api/qdb' }

  def quote_response(id, content) = { response: { quote: { quote_id: id, content: content } } }.to_json

  describe 'quotes' do
    it 'shows a random quote' do
      stub_request(:post, "#{qdb}/random").with(body: { auth_token: 'quote-key', channel: '#test' })
                                          .to_return(body: quote_response(7, 'hello world'))
      say 'bob', '.quote'
      expect(replies).to eq(['QDB#7: hello world'])
    end

    it 'shows a quote by id' do
      stub_request(:post, "#{qdb}/search/byId").with(body: hash_including(quote_id: '42'))
                                               .to_return(body: quote_response(42, 'the answer'))
      say 'bob', '.quote 42'
      expect(replies).to eq(['QDB#42: the answer'])
    end

    it 'reports unknown ids' do
      stub_request(:post, "#{qdb}/search/byId").to_return(body: { response: {} }.to_json)
      say 'bob', '.quote 999'
      expect(replies).to eq(['There is no quote by that ID'])
    end

    it 'adds quotes' do
      stub = stub_request(:post, "#{qdb}/create")
             .with(body: { auth_token: 'quote-key', channel: '#test', author: 'bob', quote: '<carol> lol' })
             .to_return(body: quote_response(43, ''))
      say 'bob', '.addquote <carol> lol'
      expect(replies).to eq(['Quote #43 added by bob!'])
      expect(stub).to have_been_requested
    end

    it 'handles authorization failures' do
      stub_request(:post, "#{qdb}/random").to_return(status: 401)
      say 'bob', '.quote'
      expect(actions_to).to eq(["isn't currently authorized to do that"])
    end

    it 'handles outages' do
      stub_request(:post, "#{qdb}/random").to_return(status: 502)
      say 'bob', '.quote'
      expect(replies).to eq(['QDB is unavailable right now'])
    end
  end

  describe 'darchoods API' do
    let(:user) do
      { status_code: 200, data: {
        user: { userstring: 'alice!alice@alice.host', nick: 'alice', identified: true, online: true,
                country: 'NL', away: false, version: 'irssi' },
        stats: { channel_count: 3, mode_counts: { q: 1, a: 0, o: 2, h: 0, v: 4 } }
      } }
    end

    it 'fingers users' do
      stub_request(:post, 'https://darchoods.net/api/irc/user/view')
        .with(body: { auth_token: 'quote-key', username: 'alice' }).to_return(body: user.to_json)
      say 'bob', '.finger alice'
      expect(replies.first).to eq('Finger → alice!alice@alice.host ~ Identified ~ Currently in 3 channels  ~ ' \
                                  'Seen Now  ~ Geo: NL ~ Available ~ Client: irssi ~ ')
    end

    it 'reports unknown users' do
      stub_request(:post, 'https://darchoods.net/api/irc/user/view')
        .to_return(body: { status_code: 200, data: { user: [] } }.to_json)
      say 'bob', '.finger ghost'
      expect(replies).to eq(['Finger → User Not Found'])
    end

    it 'shows user statistics' do
      stub_request(:post, 'https://quotes.example.org/api/irc/user/view').to_return(body: user.to_json)
      say 'bob', '.stats alice'
      expect(replies).to eq(['Statistics → alice ~ Currently in 3 ~ Owner of 1 channels ~ Admin of 0 channels ~ ' \
                             'Operator(halfop) of 2(0) channels ~ and finally voiced in 4 channels'])
    end

    it 'peeks into channels' do
      stub_request(:post, 'https://darchoods.net/api/irc/channel/view')
        .with(body: { auth_token: 'quote-key', channel: '#chat' })
        .to_return(body: { status_code: 200, data: { channel: {
          name: '#chat', modes: '+nt', stats: { current_users: 5, peak_users: 9 },
          topic: { author: 'carol', time: Time.utc(2020, 2, 3).to_i }
        } } }.to_json)
      say 'bob', '.peek #chat'
      expect(replies).to eq(['Peek → #chat (+nt) ~ Users: 5 (9x̄) ~ Last Topic set by carol @ 02/03/20'])
    end

    it 'relays peek errors' do
      stub_request(:post, 'https://darchoods.net/api/irc/channel/view')
        .to_return(body: { status_code: 500, message: 'Kaboom' }.to_json)
      say 'bob', '.peek #chat'
      expect(replies).to eq(['Peek → Kaboom'])
    end
  end
end
