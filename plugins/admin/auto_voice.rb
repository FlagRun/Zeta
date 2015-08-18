module Admin
  class BotAutoVoice
    include Cinch::Plugin
    include Cinch::Helpers

    enable_acl(:operator)

    set(
        plugin_name: "BotAuto",
        help:        "Listen's for automatic modes",
    )
    listen_to :join
    match /autovoice (on|off)$/

    # Initialization
    def initialize(*args)
      @channels = Zchannel.where(auto_voice: true).map(:name)
      super
    end

    def listen(m)
      if @channels.member? m.channel
        unless m.user.nick == bot.nick
          m.channel.voice(m.user) if m.channel.opped? bot.nick
        end
      end
    end

    def execute(m, option)
      # return false unless check_user(m, :operator)
      c = check_channel(m)
      if option == 'on'
        Zchannel.where(id: c.id).update(auto_voice: true)
        @channels = Zchannel.where(auto_voice: true).map(:name)
        m.reply 'Autovoice Enabled!'
      else
        Zchannel.where(id: c.id).update(auto_voice: false)
        @channels = Zchannel.where(auto_voice: true).map(:name)
        m.reply 'Autovoice Disabled'
      end
    end
  end
end


# AutoLoad
Zeta.config.plugins.plugins.push Admin::BotAutoVoice