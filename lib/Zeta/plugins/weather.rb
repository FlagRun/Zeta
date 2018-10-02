require 'ostruct'
require 'persist'
require 'open-uri'
require 'json'
require 'unitwise'

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
    def weather(msg, query=nil)
      # Pull data source and scrub query
      # Lookup user from pstore
      if !@store[msg.user.to_s].nil? && query.nil?
        stored_location, stored_source = @store[msg.user.to_s].split('::')
        stored_source = @api_src.include?(stored_source) ? stored_source : 'wu'
        data = send("#{stored_source}_src", stored_location)
        # location = geolookup(@store[msg.user.to_s])
        # data = wunderground_src(stored_location, false)
      elsif query.nil?
        return msg.reply 'No location set. ?setw <location> :(wu|darkscy|noaa|apixu|owm)'
      else
        # data = wu_src(query, true)
        src = query[/:\w+/].gsub(/:/, '') if query[/:\w+/]
        query = query.gsub(/:\w+/, '').strip if query
        true_src = @api_src.include?(src) ? src : 'wu'
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
      true_src = @api_src.include?(src) ? src : 'wu'
      data = send("#{true_src}_src", query)

      # Error
      return msg.reply "No results found for #{query}." if data.nil?

      # Store and display general location
      serial_location = "#{query}::#{src}"
      @store[msg.user.to_s] = serial_location unless data.nil?
      msg.reply "Your location is now set to #{data.ac.name}, #{data.ac.c}!"
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
    def almanac(msg, locale)
      autocomplete = JSON.parse(open(URI.encode("http://autocomplete.wunderground.com/aq?query=#{locale}")).read)
      url = URI.encode("http://api.wunderground.com/api/#{Config.secrets[:wunderground]}/almanac/#{autocomplete['RESULTS'][0]['l']}.json")
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
    private
    #### Weather Sources
    # Weather Underground - https://wunderground.com
    def wu_src(location)
      # Fuzzy location lookup
      ac = JSON.parse(
          open(URI.encode("https://autocomplete.wunderground.com/aq?query=#{location}")).read,
          object_class: OpenStruct
      )
      return nil if ac.RESULTS.empty?

      ac = ac.RESULTS[0]
      geolookup = JSON.parse(
          open(URI.encode("https://api.wunderground.com/api/#{Config.secrets[:wunderground]}/geolookup/#{ac.l}.json")).read,
          object_class: OpenStruct
      ).location.l rescue nil

      # Get Data
      data = JSON.parse(
          open("https://api.wunderground.com/api/#{Config.secrets[:wunderground]}/alerts/conditions#{geolookup}.json").read,
          object_class: OpenStruct
      )

      debug "DATA: #{data}"
      data.ac = ac
      current = data.current_observation
      alerts = data.alerts.empty? ? 'none' : data.alerts.map {|l| l['type']}.join(',')
      # pressure_si = Unitwise((current.pressure_in.to_f)+14.7, '[psi]').convert_to('kPa').to_f.round(2)

      data.reply = "WU ∴ #{ac.name}, #{ac.c} " \
                  "≈ #{current.weather} #{current.temperature_string} " \
                  "≈ Feels like #{current.feelslike_string} " \
                  "≈ Humidity: #{current.relative_humidity} " \
                  "≈ Pressure: #{current.pressure_in} in/Hg (#{current.pressure_mb} mbar) " \
                  "≈ Wind: #{current.wind_string} ≈ Alerts: #{alerts} ∴"
      return data
    # rescue
    #   return nil
    end

    # Open Weather map - https://openweathermap.org/api
    def owm_src(location)
      ac = JSON.parse(
          open(URI.encode("http://maps.googleapis.com/maps/api/geocode/json?address=#{location}")).read,
          object_class: OpenStruct
      )

      return nil if ac.results.nil? ## Unable to locate

      ac = ac.results[0]
      lat = ac.geometry.location.lat
      lon = ac.geometry.location.lng

      # Get Data
      data = JSON.parse(
          open(
              URI.encode("https://api.openweathermap.org/data/2.5/weather?lat=#{lat}&lon=#{lon}&APPID=#{Config.secrets[:owm]}")
          ).read,
          object_class: OpenStruct
      )

      temp = Unitwise(data.main.temp, 'K') # Data is given in kelvin
      pressure = Unitwise((data.main.pressure.to_f/10)+101, 'kPa')
      wind = Unitwise(data.wind.speed, 'kilometer')

      data.reply = "OWM ∴ #{ac.formatted_address} " \
                  "≈ #{data.weather[0].description},  #{temp.convert_to('[degF]').to_i.round(2)} F (#{temp.convert_to('Cel').to_i.round(2)} C) " \
                  "≈ Humidity: #{data.main.humidity}% " \
                  "≈ Pressure: #{pressure.convert_to('[psi]').to_f.round(2)} in/Hg (#{data.main.pressure} mbar) " \
                  "≈ Wind: #{wind.convert_to('mile').to_i.round(2)} mph (#{wind.to_i.round(2)} km/h) ∴"

      return data

    end

    # DarkSky - https://darksky.net/dev
    def darksky_src(location)
      ac = JSON.parse(
          open(URI.encode("http://maps.googleapis.com/maps/api/geocode/json?address=#{location}")).read,
          object_class: OpenStruct
      )
      return nil if ac.results.nil? ## Unable to locate

      ac = ac.results[0]
      lat = ac.geometry.location.lat
      lon = ac.geometry.location.lng

      data = JSON.parse(
          open(
              URI.encode("https://api.darksky.net/forecast/#{Config.secrets[:darksky]}/#{lat},#{lon}")
          ).read,
          object_class: OpenStruct
      )
      data.ac = ac
      current = data.currently
      alerts = data.alerts.count rescue 0
      c = Unitwise(current.temperature, '[degF]').convert_to('Cel').to_i
      c_feels = Unitwise(current.apparentTemperature, '[degF]').convert_to('Cel').to_i
      p = Unitwise((current.pressure.to_f/10)+101, 'kPa')
      gusts = Unitwise(current.windGust, 'mile').convert_to('kilometer').to_i

      tempstring = "#{current.temperature.to_i} F (#{c} C)"
      feelslike = "#{current.apparentTemperature.to_i} F (#{c_feels} C)"

      data.reply = "DS ∴ #{ac.formatted_address} " \
                  "≈ #{current.summary} #{tempstring} " \
                  "≈ Feels like #{feelslike} " \
                  "≈ Humidity: #{current.relative_humidity} " \
                  "≈ Pressure: #{p.convert_to('[psi]').to_f.round(2)} in/Hg (#{current.pressure} mbar) " \
                  "≈ Wind: gusts upto #{current.windGust} mph (#{gusts} km/h) ≈ Alerts: #{alerts} ∴"

        return data
      # rescue
      #   return nil
    end

    # NOAA - https://graphical.weather.gov/xml/
    def noaa_src(location)
      ac = JSON.parse(
          open(URI.encode("http://maps.googleapis.com/maps/api/geocode/json?address=#{location}")).read,
          object_class: OpenStruct
      )
      return nil if ac.results.nil? ## Unable to locate

      ac = ac.results[0]
      lat = ac.geometry.location.lat
      lon = ac.geometry.location.lng

      stations = JSON.parse(
          open(URI.encode("https://api.weather.gov/points/#{lat},#{lon}/stations/")).read
      ) rescue nil

      return nil if stations.nil? ## Unable to find station. probably not in the USA

      parsed = JSON.parse(
          open(URI.encode("#{stations['observationStations'][0]}/observations/current")).read,
          object_class: OpenStruct
      )


      data = parsed.properties
      data.ac = ac
      f = data.temperature.value * 9/5
      temp = "#{f.round(2)} F (#{data.temperature.value.to_i.round(2)} C) "
      wind = "Gusts: #{data.windGust.value} avg: #{data.windSpeed.value.to_i.round(2)}"
      feelslike = "#{data.windChill.value.to_i.round(2)} C"
      pressure = Unitwise(data.barometricPressure.value.to_f+101325, 'Pa')

      data.reply = "NOAA ∴ #{ac.formatted_address} " \
                  "≈ #{data.textDescription} #{temp} " \
                  "≈ Feels like #{feelslike} " \
                  "≈ Humidity: #{data.relativeHumidity.value.round(2)} " \
                  "≈ Pressure: #{pressure.convert_to('[psi]').to_f.round(2)} in/Hg (#{pressure.convert_to('kPa').to_f} mbar) " \
                  "≈ Wind: #{wind} ≈ Alerts:  ∴"
      return data
    # rescue
    #   data.reply = "Error fetching data"
    end

  end
end


# AutoLoad
Bot.config.plugins.plugins.push Plugins::Weather
