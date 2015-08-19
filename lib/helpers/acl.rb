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
      u = update_user(m)
      return false unless u
      c = u.plugin_usage.to_i + 1
      Zuser.where(id: u.id).update(plugin_usage: c)
      return false if u.ignore
      return true if u.access.to_i >= LEVELS[role]
      u
    end

    def find_user(m)
      # Determine the proper object
      if m.class == Cinch::User
        user = m
      elsif m.class == Cinch::Message
        user = m.user
      else
        return false
      end

      # Determine if the user has an authname
      if defined?(user.authname) && user.authname
        u = Zuser.find(authname: user.authname)
        if u
          Zuser.where(authname: user.authname).update(
              nickname: user.nick,
              hostname: user.host,
              username: user.user
          )
          return u
        else
          u = Zuser.create(
              nickname: user.nick,
              username: user.user,
              hostname: user.host,
              authname: user.authname
          )
          return u
        end
      else
        return false unless defined?(user.host) #just incase we create a user with User('test')
        u = Zuser.find(nickname: user.nick, hostname: user.host)
        if u
          return u
        else
          u = Zuser.create(
              nickname: user.nick,
              username: user.user,
              hostname: user.host
          )
          return u
        end
      end

    end

    def update_user(m)
      find_user(m)
    end

    def check_channel(m)
      c = find_channel(m)
      return true unless defined?(c.disabled)
      return false if c.disabled == 1
      c
    end

    def find_channel(m)
      if m.class == Cinch::Channel
        channel = m
      elsif m.class == Cinch::Message
        channel = m.channel
      else
        return false
      end

      if defined?(channel.name) && channel.name
        c = Zchannel.find(name: channel.name)
        unless c
          c = Zchannel.create(name: channel.name)
          return c
        end
      else
        c = true
      end
      c
    end

    def update_channel(m)
      find_channel(m)
    end

  end
end
