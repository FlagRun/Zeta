module Cinch
  module Plugin

    module ClassMethods
      def enable_acl(lvl= :nobody)
        hook(:pre, :for => [:match], :method => lambda { |m| check_acl(m,lvl) })
      end
    end

    LEVELS  = { banned: 0, nobody: 1, voice: 175, halfop: 191, operator: 207, admin: 223, owner: 239, founder: 255 }
    ILEVELS = LEVELS.invert

    def check_acl(message, lvl)
      if Zconf.server.services.nickserv
        unless message.user.authname
          message.user.send('You are not currently identified with services.', true)
          message.user.send('If this is in error please use the ?whois command', true)
          return false
        end
      end

      if LEVELS[lvl] <= LEVELS[:operator]
        allow_channel = check_channel(message)
      else
        allow_channel = true
      end
      allow_user = check_user(message, lvl)
      return false unless allow_user && allow_channel
    end


    def check_user(m, role=:nobody)
      u = find_user(m)
      return false if u.ignore
      return true if u.access.to_i >= LEVELS[role]
      u
    end

    def find_user(m)
      u = update_user(m)
      return false unless u
      c = u.plugin_usage.to_i + 1
      Zuser.where(id: u.id).update(plugin_usage: c)
      return u
    end

    def update_user(m)
      if defined?(m.user.authname) && m.user.authname
        u = Zuser.find(authname: m.user.authname)
        if u
          Zuser.where(authname: m.user.authname).update(
              nickname: m.user.nick,
              hostname: m.user.host,
              username: m.user.user
          )
          return u
        else
          u = Zuser.create(
              nickname: m.user.nick,
              username: m.user.user,
              hostname: m.user.host,
              authname: m.user.authname
          )
          return u
        end
      else
        return false unless defined?(m.user.host) #just incase we create a user with User('test')
        u = Zuser.find(nickname: m.user.nick, hostname: m.user.host)
        unless u
          u = Zuser.create(
              nickname: m.user.nick,
              username: m.user.user,
              hostname: m.user.host
          )
          return u
        end
      end
    end

    def check_channel(m)
      c = update_channel(m)
      return false if c.disabled == 1
      c
    end

    def update_channel(m)
      if m.channel.name
        c = Zchannel.find(name: m.channel.name)
        unless c
          c = Zchannel.create(name: m.channel.name)
          return c
        end
      end
      c
    end

  end
end
