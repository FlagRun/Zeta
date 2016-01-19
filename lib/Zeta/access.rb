module Cinch
  module Plugin

    module ClassMethods
      def enable_acl(lvl= :nobody)
        hook(:pre, :for => [:match], :method => lambda { |m| check?(m,lvl) })
      end
    end

    def check?(m, lvl)
      # Make sure we are actually getting a channel object
      if m.class == Cinch::Channel
        channel = m
      elsif m.class == Cinch::Message
        channel = m.channel
      else
        return false
      end

      # Get User
      if m.class == Cinch::User
        user = m
      elsif m.class == Cinch::Message
        user = m.user
      else
        return false
      end

      # Oper Overide
      if Config.oper_overide
        return true if user.oper
      end

      # Check Channel status
      return false if Blacklist.channels.contain? channel

      # Check Ignore status
      return false if Blacklist.users.contain? user

      # Authorization method
      if Config.auth_mode == 'channel'
        # Check lvl privilege
        case lvl
          when :q # Owner
            return true if channel.owner.include? user
          when :a # Admin
            return true if channel.admins.include? user
          when :o # Op
            return true if channel.ops.include? user
          when :h # Half-Op
            return true if channel.half_ops.include? user
          when :v # Voice
            return true if channel.voiced.include? user
          when :nobdoy
            return true
          else
            return false
        end
      elsif Config.auth_mode == 'identify'
        # TODO
        # Require you to identify with bot before usage
      elsif Config.auth_mode == 'hostmask'
        # TODO
        # Require hostmask
      end
    end

  end
end