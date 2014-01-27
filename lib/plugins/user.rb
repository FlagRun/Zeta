module Plugins
  class UserPlugin
    include Cinch::Plugin
    set prefix: /^./

    match /hello/, method: :register
    def register(m)
      unless ZUser.where(nick: m.user.nick).exists?
        ZUser.create(nick: m.user.nick, user: m.user.user, host: m.user.host)
        return m.reply "Why hello #{m.user.nick}"
      else
        return m.reply "Don't I already know you #{m.user.nick}?"
      end

    end

    match /whois(?: (.+))?/, method: :whois
    def whois(msg, target=nil)
      if ZUser.where(nick: target).exists?
        user = ZUser.where(nick: target).first

        if user.ircop
          return(msg.reply("IrcUser #{user.nick} is a COP!!!"))
        end

        return msg.reply "#{user.nick} is a #{user.level}."
      else
        return msg.reply "Who are you looking for again?"
      end

    end
  end
end