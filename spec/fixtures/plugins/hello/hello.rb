# Custom plugin fixture loaded from ~/.zeta/plugins/hello/hello.rb
module Plugins
  class Hello
    include Cinch::Plugin
    enable_acl

    match 'hello', method: :hello

    def hello(m)
      m.reply "Hello, #{m.user.nick}!"
    end
  end
end

Bot.config.plugins.plugins.push Plugins::Hello
