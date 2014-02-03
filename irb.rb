# Required Libraries
require 'libxml'
require 'dotenv'
require 'open-uri'
require 'nokogiri'
require 'json'
require 'cinch'

# Load Enviromental Variables
Dotenv.load

# Load Cinch
require_relative 'lib/core/admin'
require_relative 'lib/core/models'
require_relative 'lib/core/plugins'