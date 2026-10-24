# frozen_string_literal: true

RSpec.describe Plugins::Movie do
  let(:omdb) { 'http://www.omdbapi.com/' }
  let(:alien) do
    { Title: 'Alien', Year: '1979', Rated: 'R', Plot: ' In space no one can hear you scream. ',
      imdbID: 'tt0078748', Response: 'True' }
  end

  it 'shows the plot' do
    stub_request(:get, omdb).with(query: { t: 'Alien', y: '', apikey: 'omdb-key' }).to_return(body: alien.to_json)
    say 'bob', '.movie Alien'
    expect(replies).to eq(['Movie ⊥ Alien (1979) <R> In space no one can hear you scream. [www.imdb.com/title/tt0078748/]'])
  end

  it 'supports a :year suffix and multi-word titles' do
    stub = stub_request(:get, omdb).with(query: { t: 'Star Wars', y: '1977', apikey: 'omdb-key' })
                                   .to_return(body: alien.to_json)
    say 'bob', '.movie Star Wars:1977'
    expect(stub).to have_been_requested
  end

  it 'relays OMDb errors' do
    stub_request(:get, omdb).with(query: hash_including({}))
                            .to_return(body: { Response: 'False', Error: 'Movie not found!' }.to_json)
    say 'bob', '.movie Nope'
    expect(replies).to eq(['Movie not found!'])
  end

  it 'handles API failures' do
    stub_request(:get, omdb).with(query: hash_including({})).to_return(status: 500)
    say 'bob', '.movie Alien'
    expect(replies).to eq(['Unable to find movie!'])
  end
end
