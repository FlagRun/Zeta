module Admin
  class BotMaster
    include Cinch::Plugin
    include Cinch::Helpers

    #enable_acl()

    set(
        plugin_name: "BotMaster",
        help:        "Let the bot know who is master!.\nUsage: `/msg <bot> ?master (masterpass)`",
        react_on:    :private)

    # Regex
    match /master (.*)/, method: :master_password

    def master_password(m, pass)
      u = find_user(m)
      if u && Zconf.bot.master.password
        if Zconf.bot.master.password == pass
          Zuser.where(id: u.id).update(access: LEVELS[:founder])
          m.reply "I'm sorry I didn't recognize you sooner MASTER."
        else
          m.reply "That isn't the safe word we used last time..."
        end

      else
        m.reply 'I am unable to qualify you as master!'
      end
    end

  end
end


# AutoLoad
Zeta.config.plugins.plugins.push Admin::BotMaster