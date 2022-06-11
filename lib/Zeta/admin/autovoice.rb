module Admin
  class AutoVoice
    include Cinch::Plugin
    include Cinch::Helpers
    enable_acl()

    # Listeners
    listen_to :join, method: :autovoice

    match /autovoice (.+)/, method: :autovoice_mode

    def initialize(*args)
      @auto_voice_state = Array.new
      super
    end

    def autovoice_mode(msg, mode='status')
      return unless msg.user.oper?

      if mode == 'on' || mode == 'true'
        @auto_voice_state << msg.channel.to_s
        return msg.reply "AutoVoice is now enabled!"
      elsif mode == 'off' || mode == 'false'
        @auto_voice_state.delete_if { _1 == msg.channel.to_s }
        return msg.reply "AutoVoice is now disabled!"
      end

      msg.reply "AutoVoice is currently: #{@auto_voice_state.include?(msg.channel.to_s) ? 'On' : 'Off'}"
    end

    # Methods
    def autovoice(msg)
      if @auto_voice_state.include?(msg.channel.to_s) && msg.user.authed?
        Channel(msg.channel).voice(msg.user)
      end
    end

  end
end

# AutoLoad
Bot.config.plugins.plugins.push Admin::AutoVoice