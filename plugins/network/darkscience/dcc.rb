# module Plugins
#   class DCC
#     include Cinch::Plugin
#     set(
#         plugin_name: "DCC",
#         help: "Darkscience Code Contest.\nUsage: `~nick [channel]`;",
#         prefix: /^!/
#     )
#     match /dcc/, method: :dcc
#     match /dcc list/, method: :dcc_list
#
#     def dcc
#
#     end
#
#    private
#     def github()
#       github = Github.new oauth_token: Zsec.keys.github
#     end
#
#   end
# end
#
# # AutoLoad
# Zeta.config.plugins.plugins.push Plugins::DCC