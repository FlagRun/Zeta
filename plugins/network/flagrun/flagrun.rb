require 'uri'
require 'net/http'
require 'ostruct'
require 'action_view'

module Plugins::Flagrun
  class General
    include Cinch::Plugin
    include Cinch::Helpers
    include ActionView::Helpers::DateHelper

    self.plugin_name = 'FlagRun General'
    # self.help = '?latest'


  end
end

# AutoLoad
Zeta.config.plugins.plugins.push Plugins::Flagrun::General