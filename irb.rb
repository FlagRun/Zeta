# Required Libraries
require 'libxml'
require 'dotenv'
require 'cinch'
require 'open-uri'
require 'nokogiri'
require 'json'

# Load Enviromental Variables
Dotenv.load

# Load Cinch
require_relative 'lib/core/admin'
require_relative 'lib/core/models'
require_relative 'lib/core/plugins'
require_relative 'lib/core/helpers'