require_relative '../helpers/check_user'

module Plugins
  class DCC
    include Cinch::Plugin
    set(
        plugin_name: "DCC",
        help: "Darkscience Code Contest.\nUsage: `~nick [channel]`;",
        prefix: /^!/
    )
    match /dcc/, method: :dcc
    match /dcc list/, method: :dcc_list

    def dcc

    end

   private
    def github()
      github = Github.new oauth_token: ENV['GITHUB_KEY']
    end

  end
end