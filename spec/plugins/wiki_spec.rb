# frozen_string_literal: true

RSpec.describe Plugins::Wikipedia do
  def search_url(term) = "https://en.wikipedia.org/w/index.php?search=#{term}"

  before do
    stub_request(:get, %r{\Ahttp://is\.gd/create\.php}).to_return(body: 'https://is.gd/short')
  end

  it 'replies with the first paragraph and a short url' do
    stub_request(:get, search_url('Ruby'))
      .to_return(body: '<div id="mw-content-text"><p>Ruby is a gemstone.</p><p>More</p></div>')
    say 'bob', '.wiki Ruby'
    expect(replies).to eq(['Wiki ∴ Ruby is a gemstone. [https://is.gd/short]'])
  end

  it 'encodes spaces in search terms' do
    stub = stub_request(:get, search_url('Ruby%20on%20Rails')).to_return(body: '<div id="mw-content-text"><p>Web</p></div>')
    say 'bob', '.wikipedia Ruby on Rails'
    expect(stub).to have_been_requested.at_least_once
  end

  it 'truncates long paragraphs' do
    stub_request(:get, search_url('Long')).to_return(body: "<div id=\"mw-content-text\"><p>#{'a' * 400}</p></div>")
    say 'bob', '.wiki Long'
    expect(replies.first).to eq("Wiki ∴ #{'a' * 297}... [https://is.gd/short]")
  end

  it 'detects disambiguation pages' do
    stub_request(:get, search_url('Mercury'))
      .to_return(body: '<div id="mw-normal-catlinks">Categories: Disambiguation pages</div>')
    say 'bob', '.wiki Mercury'
    expect(replies.first).to start_with("Wiki ∴ 'Mercury is too vague and lead to a disambiguation page.")
  end

  it 'suggests alternatives when nothing is found' do
    stub_request(:get, search_url('Rubby'))
      .to_return(body: '<div class="searchdidyoumean">Did you mean: ruby</div>' \
                       '<div id="mw-content-text"><p>See Help:Searching</p></div>')
    say 'bob', '.wiki Rubby'
    expect(replies.first).to start_with("Wiki ∴ I couldn't find anything for that search, did you mean 'ruby'?")
  end

  it 'apologises when Wikipedia is unreachable' do
    stub_request(:get, search_url('Ruby')).to_raise(SocketError)
    say 'bob', '.wiki Ruby'
    expect(replies.first).to start_with("Wiki ∴ I couldn't find anything for that search, sorry!")
  end
end
