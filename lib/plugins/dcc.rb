require_relative '../helpers/check_user'

module Plugins
  class DCC
    include Cinch::Plugin
    set(
        plugin_name: "DCC",
        help: "Darkscience Code Contest.\nUsage: `~nick [channel]`;",
        prefix: /^!/
    )

  end
end