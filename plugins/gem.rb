require 'cinch/plugins/quotes'
# require 'cinch-convert'
require 'cinch-calculate'
require 'weather-underground'

Zeta.config.plugins.plugins   << Cinch::Plugins::Calculate
# Zeta.config.plugins.plugins   << Cinch::Plugins::Convert
Zeta.config.plugins.plugins   << Cinch::Plugins::Quotes

Zeta.config.plugins.options[Cinch::Plugins::Calculate][:units_path]   = '/usr/bin/units'
# Zeta.config.plugins.options[Cinch::Plugins::Convert][:units_path]     = '/usr/bin/units'
Zeta.config.plugins.options[Cinch::Plugins::Quotes][:quotes_file]     = $root_path + '/data/quotes.yml'

