# frozen_string_literal: true

RSpec.describe Plugins::Weather do
  let(:weather) { plugin(described_class) }
  let(:store) { weather.instance_variable_get(:@store) }
  let(:geocode) { 'https://maps.googleapis.com/maps/api/geocode/json' }
  let(:london) do
    { results: [{ formatted_address: 'London, UK', geometry: { location: { lat: 51.5, lng: -0.12 } } }] }.to_json
  end

  before do
    store.delete('bob')
    stub_request(:get, geocode).with(query: { address: 'london', key: 'google-key' }).to_return(body: london)
    stub_request(:get, 'https://api.openweathermap.org/data/2.5/weather')
      .with(query: { lat: '51.5', lon: '-0.12', APPID: 'owm-key' })
      .to_return(body: { main: { temp: 293.15, pressure: 1013, humidity: 50 }, wind: { speed: 10 },
                         weather: [{ description: 'clear sky' }], timezone: 3600 }.to_json)
  end

  after { store.delete('bob') }

  it 'reports OpenWeatherMap conditions' do
    travel_to(Time.utc(2026, 6, 1, 12)) { say 'bob', '.w london' }
    reply = replies.first
    expect(reply).to start_with('OWM ∴ London, UK ≈ Mon Jun  1 13:00:00 2026 ≈ clear sky, ')
    expect(reply).to match(/6[78] F \(20 C\)/)
    expect(reply).to include('Humidity: 50%', 'Pressure: 29.91 in/Hg (101.3 kPa)', 'Wind: 6 mph (10 km/h)')
  end

  %w[wx weather].each do |cmd|
    it "responds to .#{cmd}" do
      say 'bob', ".#{cmd} london :owm"
      expect(replies.first).to start_with('OWM ∴ London, UK')
    end
  end

  it 'asks for a location when none is stored' do
    say 'bob', '.w'
    expect(replies).to eq(['No location set. ?setw <location> :(noaa|owm)'])
  end

  it 'uses the stored location' do
    store['bob'] = 'london::owm'
    say 'bob', '.w'
    expect(replies.first).to start_with('OWM ∴ London, UK')
  end

  it 'reports unknown locations' do
    stub_request(:get, geocode).with(query: hash_including(address: 'atlantis')).to_return(body: '{}')
    say 'bob', '.w atlantis'
    expect(replies).to eq(['No results found for atlantis with owm source.'])
  end

  it 'reports NOAA as unavailable outside the US' do
    stub_request(:get, 'https://api.weather.gov/points/51.5,-0.12/stations/').to_return(status: 404)
    say 'bob', '.w london :noaa'
    expect(replies).to eq(['No results found for london with noaa source.'])
  end

  it 'handles geocoder responses with no results' do
    stub_request(:get, geocode).with(query: hash_including(address: 'atlantis'))
                               .to_return(body: { results: [], status: 'ZERO_RESULTS' }.to_json)
    say 'bob', '.w atlantis'
    expect(replies).to eq(['No results found for atlantis with owm source.'])
  end

  it 'stores a location with .setw' do
    say 'bob', '.setw london'
    expect(replies).to eq(['Your location is now set to London, UK!'])
    expect(store['bob']).to eq('london::owm')

    say 'bob', '.w'
    expect(replies.last).to start_with('OWM ∴ London, UK')
  end

  it 'reports a failed lookup with the stored source' do
    store['bob'] = 'atlantis::noaa'
    stub_request(:get, geocode).with(query: hash_including(address: 'atlantis')).to_return(body: '{}')
    say 'bob', '.w'
    expect(replies).to eq(['No results found for atlantis with noaa source.'])
  end

  it 'reports NOAA observations' do
    stub_request(:get, 'https://api.weather.gov/points/51.5,-0.12/stations/')
      .to_return(body: { observationStations: ['https://api.weather.gov/stations/EGLL'] }.to_json)
    stub_request(:get, 'https://api.weather.gov/stations/EGLL/observations/current')
      .to_return(body: { properties: {
        textDescription: 'Cloudy', temperature: { value: 20 }, windGust: { value: nil },
        windSpeed: { value: 11.2 }, windChill: { value: nil }, relativeHumidity: { value: 71.456 },
        barometricPressure: { value: 101_325 }
      } }.to_json)
    say 'bob', '.w london :noaa'
    expect(replies).to eq(['NOAA ∴ London, UK ≈ Cloudy 68.0 F (20 C)  ≈ Feels like 0 C ≈ Humidity: 71.46 ' \
                           '≈ Pressure: 29.92 in/Hg (101.33 kPa) ≈ Wind: Gusts:  avg: 11 ≈ Alerts:  ∴'])
  end
  it 'falls back to OpenWeatherMap for an unknown stored source' do
    store['bob'] = 'london::bogus'
    say 'bob', '.w'
    expect(replies.first).to start_with('OWM ∴ London, UK')
  end

  it 'escapes the location for the geocoder' do
    stub_request(:get, geocode).with(query: { address: 'Brighton & Hove', key: 'google-key' })
                               .to_return(body: { results: [], status: 'ZERO_RESULTS' }.to_json)
    say 'bob', '.w Brighton & Hove'
    expect(replies).to eq(['No results found for Brighton & Hove with owm source.'])
  end

  it 'escapes the location for the geocoder with NOAA' do
    stub_request(:get, geocode).with(query: { address: 'Brighton & Hove', key: 'google-key' })
                               .to_return(body: { results: [], status: 'ZERO_RESULTS' }.to_json)
    say 'bob', '.w Brighton & Hove :noaa'
    expect(replies).to eq(['No results found for Brighton & Hove with noaa source.'])
  end

  it 'reports unknown locations with .setw and keeps nothing' do
    stub_request(:get, geocode).with(query: hash_including(address: 'atlantis'))
                               .to_return(body: { results: [], status: 'ZERO_RESULTS' }.to_json)
    say 'bob', '.setw atlantis'
    expect(replies).to eq(['No results found for atlantis.'])
    expect(store['bob']).to be_nil
  end

  it 'stores a NOAA location with .setw' do
    stub_noaa
    say 'bob', '.setw london :noaa'
    expect(replies).to eq(['Your location is now set to London, UK!'])
    expect(store['bob']).to eq('london::noaa')
  end

  it 'reports fractional NOAA temperatures to two decimals' do
    stub_noaa(temperature: 21.37)
    say 'bob', '.w london :noaa'
    expect(replies.first).to start_with('NOAA ∴ London, UK ≈ Cloudy 70.47 F (21 C)  ≈')
  end

  %w[almanac hurricane].each do |cmd|
    it "ignores the retired .#{cmd} command" do
      say 'bob', ".#{cmd} london"
      expect(replies).to be_empty
    end
  end

  def stub_noaa(temperature: 20)
    stub_request(:get, 'https://api.weather.gov/points/51.5,-0.12/stations/')
      .to_return(body: { observationStations: ['https://api.weather.gov/stations/EGLL'] }.to_json)
    stub_request(:get, 'https://api.weather.gov/stations/EGLL/observations/current')
      .to_return(body: { properties: {
        textDescription: 'Cloudy', temperature: { value: temperature }, windGust: { value: nil },
        windSpeed: { value: 11.2 }, windChill: { value: nil }, relativeHumidity: { value: 71.456 },
        barometricPressure: { value: 101_325 }
      } }.to_json)
  end
end
