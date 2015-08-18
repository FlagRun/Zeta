module Admin
  class BotAccess
    include Cinch::Plugin
    include Cinch::Helpers

    enable_acl(:voice)

    # Regex
    match /setaccess (.+) (nobody|voice|halfop|operator|admin|owner)/, method: :set_access
    match /access (.+)/, method: :show_access
    match "access", method: :show_access


    def set_access(m, user, lvl)
      return m.reply("Cannot set own access!") if m.user.nick == user
      o = find_user(m)
      u = Zuser.find(authname: user) || Zuser.find(nickname: user)

      if u
        puts "Checking"
        if o.access.to_i > LEVELS[lvl.to_sym]
          Zuser.where(id: u.id).update(access: LEVELS[lvl.to_sym].to_i)
          m.reply "#{u.nickname} is now a #{lvl}!"
        else
          m.reply 'You cannot promote someone higher then yourself'
        end
      else
        m.reply "Unable to change access of user #{user}"
      end
    end

    def show_access(m, user=nil)
      u = Zuser.find(nickname: user) || find_user(m)
      access = u.access || 1
      puts access
      m.reply "#{u.nick} is a #{ILEVELS[access.to_i].to_s}"
    end

  end
end


# AutoLoad
Zeta.config.plugins.plugins.push Admin::BotAccess