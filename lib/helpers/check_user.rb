module Cinch
  module Helpers

    def check_user(m, role=:nobody)
      return true if Zconf.master == m.user.authname
      case role
        when :master || :god
          Zconf.master == m.user.authname
        when :owner || :w
         return true if Zusers.owner.split(' ').include? m.user.authname
        when :admin || :a
          return true if Zusers.owner.split(' ').include? m.user.authname
          return true if Zusers.admin.split(' ').include? m.user.authname
        when :operator || :o
          return true if Zusers.owner.split(' ').include?(m.user.authname)
          return true if Zusers.admin.split(' ').include?(m.user.authname)
          return false if Zignore.users.split(' ').include? m.user.nick
          return true if Zusers.operator.split(' ').include? m.user.authname
        when :voice || :v
          return true if Zusers.owner.split(' ').include?(m.user.authname)
          return true if Zusers.admin.split(' ').include?(m.user.authname)
          return false if Zignore.users.split(' ').include? m.user.nick
          return true if Zusers.operator.split(' ').include? m.user.authname
          return true if Zusers.voice.split(' ').include? m.user.authname
        when :nobody
          return false if m.user.authname == nil
          return false if Zignore.users.split(' ').include? m.user.nick
          true
        else
          false
      end
    end

    def check_channel(m)
      true unless Zignore.channels.split(' ').include? m.channel
    end

    def check(channel, user, ignored_members=nil)
      ignored_members ||= [] # If nil, assign an empty array.
      users = Channel(channel).users # All users from supplied channel
      modes = @bot.irc.isupport["PREFIX"].keys - ignored_members
      modes.any? {|mode| users[user].include?(mode)}
    end

    def check_network(network)
      @bot.irc.network.name  == network
    end


  end

end