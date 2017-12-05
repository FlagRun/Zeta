module Cinch
  module Plugin

    module ClassMethods
      def enable_acl(lvl= :nobody, secure_chan=false)
        hook(:pre, :for => [:match], :method => lambda { |m| check?(m,lvl,secure_chan) })
      end
    end

    Spam = Struct.new(:nick, :time)

    def check?(m, lvl, secure_chan)
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
        # Do Not overide in #services
        unless channel.to_s == "#services"
          if user.oper
            user.refresh
            return true
          end
        end
      end

      # Check Channel status
      return false if Blacklist.channels.include? channel.to_s

      # Check Ignore status
      return false if Blacklist.users.include? user.to_s

      # Only check if user has permission in the secure channel
      channel = Channel(Config.secure_channel.to_s) if secure_chan

      # Authorization method
      if Config.secure_mode == 'channel'
        # Check lvl privilege
        case lvl
          when :O, :oper
            if user.oper
              user.refresh
              return true
            end
            false
          when :q, :owner # Owner
            return true if channel.owners.include? user
            false
          when :a, :admin # Admin
            return true if channel.admins.include? user
            false
          when :o, :op # Op
            return true if channel.ops.include? user
            false
          when :h, :halfop # Half-Op
            return true if channel.half_ops.include? user
            false
          when :v, :voice # Voice
            return true if channel.voiced.include? user
            false
          when :nobody
            return true
          else
            return false
        end
      elsif Config.secure_mode == 'identify'
        # TODO
        # Require you to identify with bot before usage
      elsif Config.secure_mode == 'hostmask'
        # TODO
        # Require hostmask
      end
    end

    def log2chan(msg, level=:notice)
      Channel(Config.log_channel.to_s).send "[#{level.to_s}] #{msg}"
    end

  end
end