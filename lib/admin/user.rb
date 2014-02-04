require_relative '../helpers/check_user'

module Admin
  class UserAdmin
    include Cinch::Plugin

    set(
        plugin_name: 'UserAdmin',
        help: "Bot administrator-only private commands.\nUsage: `~set admin [user]`; `~set op [user] `; `~set hop [user]`; `~set voice [user] `;",
        prefix: /^~/
    )

    ############### Set Permission

    match /set admin (.+)/, method: :set_admin
    def set_admin(m, t)
      return unless get_user(m).is_owner?
      return m.reply('Who do you want to make an admin?') if t.nil?
      u = Zuser.find(nick: t)
      if u
        u.role = :a
        if u.save
          DB.disconnect
          return m.reply("#{t} is now an Admin.")
        else
          return m.reply("I was unable to Admin #{t}")
        end
      else
        return m.reply("Couldn't find #{t}")
      end
    end

    match /set op (.+)/, method: :set_op
    def set_op(m, t)
      return unless get_user(m).is_admin?
      return m.reply('Who do you want to make an Op?') if t.nil?
      u = Zuser.find(nick: t)
      if u
        u.role = :o
        if u.save
          DB.disconnect
          return m.reply("#{t} is now an Op.")
        else
          return m.reply("I was unable to Op #{t}")
        end
      else
        return m.reply("Couldn't find #{t}")
      end
    end

    match /set hop (.+)/, method: :set_hop
    def set_hop(m, t)
      return unless get_user(m).is_op?
      return m.reply('Who do you want to make an HalfOp?') if t.nil?
      u = Zuser.find(nick: t)
      if u
        u.role = :h
        if u.save
          DB.disconnect
          return m.reply("#{t} is now an HalfOp.")
        else
          return m.reply("I was unable to HalfOp #{t}")
        end
      else
        return m.reply("Couldn't find #{t}")
      end
    end

    match /set voice (.+)/, method: :set_voice
    def set_voice(m, t)
      return unless get_user(m).is_halfop?
      return m.reply('Who do you want to make an Voice?') if t.nil?
      u = Zuser.find(nick: t)
      if u
        u.role = :v
        if u.save
          DB.disconnect
          return m.reply("#{t} is now an Voice.")
        else
          return m.reply("I was unable to Voice #{t}")
        end
      else
        return m.reply("Couldn't find #{t}")
      end
    end

    match /set nobody (.+)/, method: :set_nobody
    def set_nobody(m, t)
      return unless get_user(m).is_halfop?
      return m.reply('Who do you want to make an Nobody?') if t.nil?
      u = Zuser.find(nick: t)
      if u
        u.role = false
        if u.save
          DB.disconnect
          return m.reply("#{t} is now an Nobody.")
        else
          return m.reply("I was unable to Nobody #{t}")
        end
      else
        return m.reply("Couldn't find #{t}")
      end
    end




    #####################



    ##
  end
end