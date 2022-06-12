require 'ostruct'
require 'persist'
require 'open-uri'
require 'json'
require 'unitwise'
require 'tzinfo'

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

    match /w (.+)/, method: :weather
    match 'w', method: :weather
    match /setw (.+)/, method: :set_location
    match /wx (.+)/, method: :weather
    match /weather (.+)/, method: :weather
    match /almanac (.+)/, method: :almanac
    match /hurricane/, method: :hurricane

    #####
    def initialize(*args)
      @api_src = %w{wu noaa darksky owm}
      @store = Persist.new(File.join(Dir.home, '.zeta', 'cache', 'weather.pstore'))
      super
    end

    # ?w <location>
    def weather(msg, query = nil)
      # Pull data source and scrub query
      # Lookup user from pstore
      if !@store[msg.user.to_s].nil? && query.nil?
        stored_location, stored_source = @store[msg.user.to_s].split('::')
        stored_source = @api_src.include?(stored_source) ? stored_source : 'darksky'
        data = send("#{stored_source}_src", stored_location)
        # location = geolookup(@store[msg.user.to_s])
        # data = wunderground_src(stored_location, false)
      elsif query.nil?
        return msg.reply 'No location set. ?setw <location> :(darksky|noaa|apixu|owm)'
      else
        # data = wu_src(query, true)
        src = query[/:\w+/].gsub(/:/, '') if query[/:\w+/]
        query = query.gsub(/:\w+/, '').strip if query
        true_src = @api_src.include?(src) ? src : 'darksky'
        data = send("#{true_src}_src", query)
      end

      return msg.reply "No results found for #{query} with #{true_src} source." if data.nil?

      # return msg.reply 'Problem getting data. Try again later.' if data.nil?
      msg.reply(data.reply)
    end

    # ?setw <location>
    def set_location(msg, query)
      # Establish source
      src = query[/:\w+/].gsub(/:/, '') if query[/:\w+/]
      query = query.gsub(/:\w+/, '').strip if query

      # Sanity Check
      true_src = @api_src.include?(src) ? src : 'darksky'
      data = send("#{true_src}_src", query)

      # Error
      return msg.reply "No results found for #{query}." if data.nil?

      # Store and display general location
      serial_location = "#{query}::#{src}"
      @store[msg.user.to_s] = serial_location unless data.nil?
      msg.reply "Your location is now set to #{data.ac.name}, #{data.ac.c}!"
    end

    # -private
    private

    # Open Weather map - https://openweathermap.org/api
    def owm_src(location)
      location = CGI.escape(location)

      ac = JSON.parse(
        RestClient.get(
          "https://maps.googleapis.com/maps/api/geocode/json?address=#{location}&key=#{Config.secrets[:google]}"
        ).body, object_class: OpenStruct
      )

      return nil if ac.results.nil? ## Unable to locate

      ac = ac.results[0]
      lat = ac.geometry.location.lat
      lon = ac.geometry.location.lng

      # Get Data
      data = JSON.parse(
        RestClient.get("https://api.openweathermap.org/data/2.5/weather?lat=#{lat}&lon=#{lon}&APPID=#{Config.secrets[:owm]}"
        ).body, object_class: OpenStruct
      )

      temp = Unitwise(data.main.temp, 'K') # Data is given in kelvin
      pressure = Unitwise(data.main.pressure.to_f, 'mbar')
      wind = Unitwise(data.wind.speed, 'kilometer')

      data.reply = "OWM ∴ #{ac.formatted_address} " \
                  "≈ #{(Time.now.utc + data.timezone.seconds).strftime("%c")} " \
                  "≈ #{data.weather[0].description},  #{temp.convert_to('[degF]').to_i.round(2)} F (#{temp.convert_to('Cel').to_i.round(2)} C) " \
                  "≈ Humidity: #{data.main.humidity.to_i.round(2)}% " \
                  "≈ Pressure: #{pressure.convert_to('[in_i\'Hg]').to_f.round(2)} in/Hg " \
                  "(#{pressure.convert_to("kPa").to_f.round(2)} kPa) " \
                  "≈ Wind: #{wind.convert_to('mile').to_i.round(2)} mph (#{wind.to_i.round(2)} km/h) ∴"

      return data
    end

    # DarkSky - https://darksky.net/dev
    def darksky_src(location)
      location = CGI.escape(location)

      ac = JSON.parse(
        RestClient.get("https://maps.googleapis.com/maps/api/geocode/json?address=#{location}&key=#{Config.secrets[:google]}").body,
        object_class: OpenStruct
      )
      return nil if ac.results.nil? ## Unable to locate

      ac = ac.results[0]
      lat = ac.geometry.location.lat
      lon = ac.geometry.location.lng

      data = JSON.parse(
        RestClient.get("https://api.darksky.net/forecast/#{Config.secrets[:darksky]}/#{lat},#{lon}").body,
        object_class: OpenStruct
      )
      data.ac = ac
      current = data.currently
      alerts = data.alerts.count rescue 0
      c = Unitwise(current.temperature, '[degF]').convert_to('Cel').to_i
      c_feels = Unitwise(current.apparentTemperature, '[degF]').convert_to('Cel').to_i
      p = Unitwise(current.pressure.to_f, 'mbar')
      gusts = Unitwise(current.windGust, 'mile').convert_to('kilometer').to_i

      tempstring = "#{current.temperature.to_i} F (#{c} C)"

      data.reply = "DS ∴ #{ac.formatted_address} " \
                  "≈ #{TZInfo::Timezone.get(data.timezone).now.strftime("%c")} " \
                  "≈ #{current.summary} #{tempstring} " \
                  "≈ Humidity: #{(current.humidity * 100).round(2)}% " \
                  "≈ Pressure: #{p.convert_to('[in_i\'Hg]').to_f.round(2)} in/Hg " \
                  "(#{p.convert_to("kPa").to_f.round(2)} kPa) " \
                  "≈ Wind: gusts upto #{current.windGust} mph (#{gusts} km/h) ≈ Alerts: #{alerts} ∴"

      return data
      # rescue
      #   return nil
    end

    # NOAA - https://graphical.weather.gov/xml/
    def noaa_src(location)
      location = CGI.escape(location)

      ac = JSON.parse(
        RestClient.get("https://maps.googleapis.com/maps/api/geocode/json?address=#{location}&key=#{Config.secrets[:google]}").body,
        object_class: OpenStruct
      )
      return nil if ac.results.nil? ## Unable to locate

      ac = ac.results[0]
      lat = ac.geometry.location.lat
      lon = ac.geometry.location.lng

      stations = JSON.parse(
        RestClient.get("https://api.weather.gov/points/#{lat},#{lon}/stations/").body
      ) rescue nil

      return nil if stations.nil? ## Unable to find station. probably not in the USA

      parsed = JSON.parse(
        RestClient.get("#{CGI.escape(stations['observationStations'][0])}/observations/current").body,
        object_class: OpenStruct
      )

      data = parsed.properties
      data.ac = ac
      f = data.temperature.value * 9 / 5
      temp = "#{f.round(2)} F (#{data.temperature.value.to_i.round(2)} C) "
      wind = "Gusts: #{data.windGust.value} avg: #{data.windSpeed.value.to_i.round(2)}"
      feelslike = "#{data.windChill.value.to_i.round(2)} C"
      pressure = Unitwise(data.barometricPressure.value.to_f, 'Pa')

      data.reply = "NOAA ∴ #{ac.formatted_address} " \
                  "≈ #{data.textDescription} #{temp} " \
                  "≈ Feels like #{feelslike} " \
                  "≈ Humidity: #{data.relativeHumidity.value.round(2)} " \
                  "≈ Pressure: #{pressure.convert_to('[in_i\'Hg]').to_f.round(2)} in/Hg " \
                  "(#{pressure.convert_to("kPa").to_f.round(2)} kPa) " \
                  "≈ Wind: #{wind} ≈ Alerts:  ∴"
      return data
      # rescue
      #   data.reply = "Error fetching data"
    end
  end
end

# AutoLoad
Bot.config.plugins.plugins.push Plugins::Weather
