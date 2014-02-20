module Plugins
  class Register
    include Cinch::Plugin
    set(
        plugin_name: "Register",
        help: "Register with Zbot!\nUsage: `!hello`",
    )

    match /hello/, method: :register
    def register(m)
      return m.reply('You are not identified by NickServ') if m.user.authname == nil
      ircop = defined?(m.user.oper?) ? m.user.oper? : false

      unless Zuser.find(nick: m.user.nick)
        Zuser.create(nick: m.user.nick, user: m.user.user, host: m.user.host, authname:m.user.authname, ircop: ircop)
        DB.disconnect
        m.reply "Well hello #{m.user.nick}."
      else
        m.reply "Don't I already know you #{m.user.nick}?"
      end

    end

    match /whois(?: (.+))?/, method: :whois
    def whois(msg, target=nil)

      user = Zuser.find(nick: target)
      DB.disconnect
      if user
        return(msg.reply("#{user.nick} is a COP!!!")) if user.ircop
        return msg.reply("{user.nick} you are a #{user.level}.") if user.nick == msg.user.nick

        msg.reply "#{user.nick} is a #{user.level}."
      else
        msg.reply "Who are you looking for again?"
      end

    end
  end
end