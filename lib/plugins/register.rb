module Plugins
  class Register
    include Cinch::Plugin
    set(
        plugin_name: "Register",
        help: "Register with Zbot!\nUsage: `!hello`",
    )

    match /hello/, method: :register
    def register(m)
      unless Zuser.where(nick: m.user.nick).exists?
        Zuser.create(nick: m.user.nick, user: m.user.user, host: m.user.host)
        return m.reply "Well hello #{m.user.nick}"
      else
        return m.reply "Don't I already know you #{m.user.nick}?"
      end

    end

    match /whois(?: (.+))?/, method: :whois
    def whois(msg, target=nil)
      user = Zuser.where(nick: target).first
      if user
        if user.ircop
          return(msg.reply("#{user.nick} is a COP!!!"))
        end

        return msg.reply "#{user.nick} is a #{user.level}."
      else
        return msg.reply "Who are you looking for again?"
      end

    end
  end
end