# encoding: utf-8
Encoding.default_internal = 'utf-8'
Encoding.default_external = 'utf-8'

require 'json'
require 'time'
require 'date'
require 'sinatra/base'
require 'sinatra/async'
require 'redis'
require 'sinatra'
require 'haml'
require 'sinatra/twitter-bootstrap'
require_relative 'core/models'

module WWW
  class App < Sinatra::Base
    register Sinatra::Twitter::Bootstrap::Assets

    configure do
      set :public_folder, File.dirname(__FILE__) + '../public'
      set :protection, :except => :frame_options
    end

    get "/" do
      redirect "/channel/flagrun/today"
    end

    get "/channel/:channel" do |channel|
      redirect "/channel/#{channel}/today"
    end

    get "/channel/:channel/:date" do |channel, date|
      case date
        when "today"
          @date = Time.now.strftime("%F")
        when "yesterday"
          @date = (Time.now - 86400).strftime("%F")
        else
          # date in "%Y-%m-%d" format (e.g. 2013-01-01)
          @date = date
      end

      @channel = channel

      @msgs = Chatlog.where(:time.lte => @date)
      #@msgs = @msgs.map {|msg|
      #  msg = JSON.parse(msg)
      #  if msg["msg"] =~ /^\u0001ACTION (.*)\u0001$/
      #    msg["msg"].gsub!(/^\u0001ACTION (.*)\u0001$/, "<span class=\"nick\">#{msg["nick"]}</span>&nbsp;\\1")
      #    msg["nick"] = "*"
      #  end
      #}

      haml :channel
    end

    get "/widget/:channel" do |channel|
      @channel = channel
      today = Time.now.strftime("%Y-%m-%d")
      #@msgs = $redis.lrange("irclog:channel:##{channel}:#{today}", -25, -1)
      @msgs = Chatlog.where(time.lte @date)
      @msgs = @msgs.map {|msg| JSON.parse(msg) }.reverse

      erb :widget
    end
  end
end

