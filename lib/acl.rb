module Cinch
  module Extensions
    class ACL
      def initialize
        @defaults = {:authname => {}, :channel => {}}
        @acls = {
            :authname => Hash.new { |h, k| h[k] = {} },
            :channel => Hash.new { |h, k| h[k] = {} },
        }
      end

      # @param [:authname, :channel] type
      # @param [Class] plugin
      # @param [:allow, :disallow] value
      def set_default(type, plugin, value)
        @defaults[type][plugin] = value
      end

      # @param [:authname, :channel] type
      # @param [Class] plugin
      # @param [String] name
      # @return [void]
      def allow(type, plugin, name)
        if type != :authname && type != :channel
          raise ArgumentError, "type must be one of [:authname, :channel]"
        end

        @acls[type][plugin][name] = :allow
      end

      # @param [:authname, :channel] type
      # @param [Class] plugin
      # @param [String] name
      # @return [void]
      def disallow(type, plugin, name)
        if type != :authname && type != :channel
          raise ArgumentError, "type must be one of [:authname, :channel]"
        end

        @acls[type][plugin][name] = :disallow
      end

      # @param [Message] message
      # @param [Plugin] plugin
      # @return [Boolean]
      def check(message, plugin)
        channel_name = message.channel && message.channel.name.irc_downcase(message.bot.irc.isupport["CASEMAPPING"])
        authname_name = message.user && message.user.authname

        authname_allowed = get_acl(plugin, :authname, authname_name) == :allow
        channel_allowed = channel_name.nil? || get_acl(plugin, :channel, channel_name) == :allow

        authname_allowed && channel_allowed
      end

      private
      # @param [Plugin] plugin
      # @param [:authname, :channel] type
      # @param [String] name
      # @return [:allow, :disallow]
      def get_acl(plugin, type, name)
        plugin = plugin.class
        @acls[type][plugin][name] || @defaults[type][plugin] || @defaults[type][nil]
      end

    end
  end
end