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

    ############### Delete Permission

    match /del admin (.+)/, method: :del_admin
    def del_admin(m, t)
      return unless get_user(m).is_owner?
      return m.reply('Who do you want to make an admin?') if t.nil?
      u = Zuser.find(nick: t)
      if u
        u.role = :a
        if u.save
          DB.disconnect
          return m.reply("#{t} is no longer an Admin.")
        else
          return m.reply("I was unable to remove  Admin #{t}")
        end
      else
        return m.reply("Couldn't find #{t}")
      end
    end

    match /del op (.+)/, method: :del_op
    def del_op(m, t)
      return unless get_user(m).is_admin?
      return m.reply('Who do you want to make an Op?') if t.nil?
      u = Zuser.find(nick: t)
      if u
        u.role = :o
        if u.save
          DB.disconnect
          return m.reply("#{t} is no longer an Op.")
        else
          return m.reply("I was unable to remove  Op #{t}")
        end
      else
        return m.reply("Couldn't find #{t}")
      end
    end

    match /del hop (.+)/, method: :del_hop
    def del_hop(m, t)
      return unless get_user(m).is_op?
      return m.reply('Who do you want to make an HalfOp?') if t.nil?
      u = Zuser.find(nick: t)
      if u
        u.role = :h
        if u.save
          DB.disconnect
          return m.reply("#{t} is no longer an HalfOp.")
        else
          return m.reply("I was unable to remove  HalfOp #{t}")
        end
      else
        return m.reply("Couldn't find #{t}")
      end
    end

    match /del voice (.+)/, method: :del_voice
    def del_voice(m, t)
      return unless get_user(m).is_halfop?
      return m.reply('Who do you want to make an Voice?') if t.nil?
      u = Zuser.find(nick: t)
      if u
        u.role = :v
        if u.save
          DB.disconnect
          return m.reply("#{t} is no longer an Voice.")
        else
          return m.reply("I was unable to remove  Voice #{t}")
        end
      else
        return m.reply("Couldn't find #{t}")
      end
    end

    #####################



    ##
  end
end