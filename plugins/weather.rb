require 'ostruct'

module Plugins
  # Forecast is a Cinch plugin for getting the weather forecast.
  # @author Jonah Ruiz <jonah@pixelhipsters.com>
  class Forecast
    include Cinch::Plugin

    match /forecast (.+)/, method: :forecast
    # Executes the geolookup and get_conditions method when Regexp is matched
    #
    # @param msg [Cinch::Bot] passed internally by the framework.
    # @param query [String] zipcode captured by the match method.
    # @return [String] weather summary to IRC channel.
    def forecast(msg, query)

      location = geolookup(query)
      return msg.reply "No results found for #{query}." if location.nil?

      data = get_conditions(location)
      return msg.reply 'Problem getting data. Try again later.' if data.nil?

      msg.reply(weather_summary(data))
    end

    match /w (.+)/, method: :weather
    match /wx (.+)/, method: :weather
    match /weather (.+)/, method: :weather
    def weather(msg, query)


      location = geolookup(query)
      return msg.reply "No results found for #{query}." if location.nil?

      data = get_conditions(location)
      return msg.reply 'Problem getting data. Try again later.' if data.nil?

      #[ Clarkston, WA, United States | Cloudy | Temp: 34 F (1 C) | Humidity: 73% | Winds: 8 mph ]
      reply_data = "|:: #{data.county}, #{data.country} " \
                  ":|: #{data.weather} #{data.feels_like} " \
                  ":|: Humidity: #{data.relative_humidity} " \
                  ":|: Pressure: #{data.pressure_mb} mmHg " \
                  ":|: Wind: #{data.wind_mph} mph gusting to #{data.wind_gust_mph} mph ::|"
      msg.reply(reply_data)
    end


    # Finds location for zipcode
    #
    # @param zipcode [String] zipcode
    # @return [String] location-specific parameter for getting conditions.
    def geolookup(zipcode)
      location = JSON.parse(open("http://api.wunderground.com/api/#{Zsec.key.wunderground}/geolookup/q/#{zipcode}.json").read)
      location['location']['l']
    rescue
      nil
    end

    # Fetches weather conditions and formats output
    #
    # @param location [String] provided by the geolookup method
    # @return [OpenStruct] parsed weather conditions.
    def get_conditions(location)
      data = JSON.parse(open("http://api.wunderground.com/api/#{Zsec.key.wunderground}/conditions#{location}.json").read)
      current = data['current_observation']
      location_data = current['display_location']

      OpenStruct.new(
          county: location_data['full'],
          country: location_data['country'],

          lat: location_data['latitude'],
          lng: location_data['longitude'],

          observation_time: current['observation_time'],
          weather: current['weather'],
          temp_fahrenheit: current['temp_f'],
          temp_celcius: current['temp_c'],
          relative_humidity: current['relative_humidity'],
          feels_like: current['feelslike_string'],
          uv_level: current['UV'],

          wind: current['wind_string'],
          wind_direction: current['wind_dir'],
          wind_degrees: current['wind_degrees'],
          wind_mph: current['wind_mph'],
          wind_gust_mph: current['wind_gust_mph'],
          wind_kph: current['wind_kph'],
          pressure_mb: current['pressure_mb'],

          forecast_url: current['forecast_url']
      )
    rescue
      nil
    end

    # Displays weather summary for IRC output
    #
    # @param data [OpenStruct] weather conditions data
    # @return [String] weather summary.
    def weather_summary(data)
      ##
      # Sample Summary using !forecast 00687
      # Forecast for: Morovis, PR, US
      # Latitude: 18.32682228, Longitude: -66.40519714
      # Weather is Partly Cloudy, feels like 85 F (27.1 C)
      # UV: 9.5, Humidity: 78%
      # Wind: From the SE at 1.0 MPH Gusting to 5.0 MPH
      # Direction: East, Degrees: 90
      # Last Updated on June 4, 11:25 PM AST
      # More Info: http://www.wunderground.com/US/PR/Morovis.html

      %Q{
          Forecast for: #{data.county}, #{data.country}
          Latitude: #{data.lat}, Longitude: #{data.lng}
          Weather is #{data.weather}, #{data.feels_like}
          UV: #{data.uv_level}, Humidity: #{data.relative_humidity}
          Wind: #{data.wind}
          Direction: #{data.wind_direction}, Degrees: #{data.wind_degrees},
          #{data.observation_time}
          More Info: #{data.forecast_url}}
    rescue
      'Problem fetching the weather summary. Try again later.'
    end
  end
end


# AutoLoad
Zeta.config.plugins.plugins.push Plugins::Forecast
