# frozen_string_literal: true

RSpec.describe Plugins::DNSBlacklist do
  def lookup_returns(results)
    client = instance_double(DNSBL::Client)
    allow(DNSBL::Client).to receive(:new).and_return(client)
    allow(client).to receive(:lookup).with('192.0.2.1').and_return(results)
  end

  def hit(dnsbl, meaning)
    instance_double(DNSBL::DNSBLResult, dnsbl: dnsbl, meaning: meaning)
  end

  it 'reports clean hosts' do
    lookup_returns([])
    say 'bob', '.dnsbl 192.0.2.1 '
    expect(replies).to eq(['No Results Found (192.0.2.1 )'])
  end

  it 'reports listings' do
    lookup_returns([hit('SBL', 'spam'), hit('XBL', 'exploited host')])
    say 'bob', '.blacklist 192.0.2.1'
    expect(replies).to eq(['Listed ⁘ 192.0.2.1 ⁜ exploited host ⁜ Hits: 2'])
  end

  it 'treats the URIBL test answer as clean' do
    lookup_returns([hit('URIBL', '127.0.0.1')])
    say 'bob', '.dnsbl 192.0.2.1'
    expect(replies).to eq(['No Results Found (192.0.2.1)'])
  end
end
