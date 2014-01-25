require File.join(File.dirname(__FILE__), 'lib/sinatra')

run Rack::URLMap.new \
  '/' => WWW::App.new