require 'ostruct'
require 'persist'

module Plugins
  # Forecast is a Cinch plugin for getting the weather forecast.
  # @original_author Jonah Ruiz <jonah@pixelhipsters.com>
  # @author Liothen <liothen@flagrun.net>
  class Weather
    include Cinch::Plugin
    include Cinch::Helpers
    enable_acl

    set(
        plugin_name: "Weather",
        help: "Get the Weather?.\nUsage: `?weather`\nUsage: `?wx zip` `?w zip` `?setw zip` `?forecast zip`",
    )

    match /forecast (.+)/, method: :forecast
    match /w (.+)/, method: :weather
    match 'w', method: :weather
    match /setw (.+)/, method: :set_location
    match /wx (.+)/, method: :weather
    match /weather (.+)/, method: :weather
    match /almanac (.+)/, method: :almanac
    match /hurricane/, method: :hurricane

    #####
    def initialize(*args)
      @store = Persist.new File.path($root_path + '/data/user/weather.pstore')
      super
    end

    # ?forecast <location>
    def forecast(msg, query)
      location = geolookup(query)
      return msg.reply "No results found for #{query}." if location.nil?

      data = get_conditions(location)
      return msg.reply 'Problem getting data. Try again later.' if data.nil?

      msg.user.msg(weather_summary(data))
    end

    # ?w <location>
    def weather(msg, query=nil)
      u = find_user(msg)
      if u.location && query.nil?
        location = geolookup(u.location)
      elsif query.nil?
        return msg.reply 'No location set. ?setw <location>'
      else
        location = geolookup(query)
      end
      return msg.reply "No results found for #{query}." if location.nil?

      data = get_conditions(location)
      return msg.reply 'Problem getting data. Try again later.' if data.nil?

      #[ Clarkston, WA, United States | Cloudy | Temp: 34 F (1 C) | Humidity: 73% | Winds: 8 mph ]
      reply_data = "∴ #{data.county}, #{data.country} " \
                  "≈ #{data.weather} #{data.temperature} " \
                  "≈ Humidity: #{data.relative_humidity} " \
                  "≈ Pressure: #{data.pressure_in} psi (#{data.pressure_mb} mmHg) " \
                  "≈ Wind: #{data.wind} ≈ Alerts: #{data.alerts} ∴"
      msg.reply(reply_data)
    end

    # ?setw <location>
    def set_location(msg,query)
      location = geolookup(query)
      u = find_user(msg)
      return msg.reply "No results found for #{query}." if location.nil?
      Zuser.where(id: u.id).update(location: query) unless location.nil?
      data = get_conditions(location)
      msg.reply "Your location is now set to #{data.county}, #{data.country}!"
    end

    # ?hurricane
    def hurricane(msg)
      url = URI.encode "http://api.wunderground.com/api/#{Zsec.wunderground}/currenthurricane/view.json"
      location = JSON.parse(
           # RestClient.get(url)
           open(url).read
       )
      return msg.reply "No results found for #{query}." if location.nil?
      reply_msg = "∴ #{location['currenthurricane'][0]['stormInfo']['stormName_Nice']} " \
                  "(#{location['currenthurricane'][0]['stormInfo']['stormNumber']}) "\
                  "≈ Category #{location['currenthurricane'][0]['Current']['SaffirSimpsonCategory']} " \
                  "≈ Wind #{location['currenthurricane'][0]['Current']['WindSpeed']['Mph']} mph " \
                  "(#{location['currenthurricane'][0]['Current']['WindSpeed']['Kph']} kph) " \
                  "≈ Wind Gust #{location['currenthurricane'][0]['Current']['WindGust']['Mph']} mph " \
                  "(#{location['currenthurricane'][0]['Current']['WindGust']['Kph']} kph) " \
                  "≈ #{location['currenthurricane'][0]['Current']['Time']['pretty']} ∴"
      msg.reply(reply_msg)
    end

    # ?almanac <location>
    def almanac(msg,locale)
      url = URI.encode "http://api.wunderground.com/api/#{Zsec.wunderground}/almanac/q/#{locale}.json"
      location = JSON.parse(
           # RestClient.get(url)
           open(url).read
       )
      return msg.reply "No results found for #{query}." if location.nil?

      time = Time.now()

      data = OpenStruct.new(
          date: time.strftime('%B, %d %Y (%A) '),
          airport: location['almanac']['airport_code'],
          high_norm_f: location['almanac']['temp_high']['normal']['F'],
          high_norm_c: location['almanac']['temp_high']['normal']['C'],
          high_record_y: location['almanac']['temp_high']['recordyear'],
          high_record_f: location['almanac']['temp_high']['record']['F'],
          high_record_c: location['almanac']['temp_high']['normal']['C'],
          low_norm_f: location['almanac']['temp_low']['normal']['F'],
          low_norm_c: location['almanac']['temp_low']['normal']['C'],
          low_record_y: location['almanac']['temp_low']['recordyear'],
          low_record_f: location['almanac']['temp_low']['record']['F'],
          low_record_c: location['almanac']['temp_low']['normal']['C'],
      )

      reply_msg = "∴ Almanac #{data.date} ≈ Airport #{data.airport} " \
              "≈ Normal #{data.high_norm_f} F (#{data.high_norm_c} C) | #{data.low_norm_f} F (#{data.low_norm_c} C) " \
              "≈ High #{data.high_record_f} F (#{data.high_record_c} C) [#{data.high_record_y}] " \
              "≈ Low #{data.low_record_f} F (#{data.low_record_c} C) [#{data.low_record_y}] ∴"

      msg.reply(reply_msg)
    end


    # -private
    def geolookup(locale)
      url = URI.encode "http://api.wunderground.com/api/#{Zsec.wunderground}/geolookup/q/#{locale}.json"
      location = JSON.parse(
          # RestClient.get(url).force_encoding("UTF-8")
          open(url).read
      )
      location['location']['l']
    rescue
      nil
    end

    def get_conditions(location)
      data = JSON.parse(
          open("http://api.wunderground.com/api/#{Zsec.wunderground}/alerts/conditions#{location}.json").read
          #RestClient.get("http://api.wunderground.com/api/#{Zsec.wunderground}/conditions#{location}.json")
      )
      current = data['current_observation']
      alerts = data['alerts'].empty? ? 'none' : data['alerts'].map { |l| l['type'] }.join(',')
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
          temperature: current['temperature_string'],
          relative_humidity: current['relative_humidity'],
          feels_like: current['feelslike_string'],
          uv_level: current['UV'],

          wind: current['wind_string'],
          wind_direction: current['wind_dir'],
          wind_degrees: current['wind_degrees'],
          wind_mph: current['wind_mph'],
          wind_gust_mph: current['wind_gust_mph'],
          wind_kph: current['wind_kph'],
          pressure_in: current['pressure_in'],
          pressure_mb: current['pressure_mb'],

          alerts: alerts,

          forecast_url: current['forecast_url']
      )
    rescue
      nil
    end

    def weather_summary(data)
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
Zeta.config.plugins.plugins.push Plugins::Weather
