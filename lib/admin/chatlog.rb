module Admin
  class ChatlogAdmin
    include Cinch::Plugin

    set(
      plugin_name: 'ChatlogAdmin',
      help: "Bot administrator-only private commands.\nUsage: `~join [channel]`; `~part [channel] <reason>`; `~quit [reason]`;",
      prefix: /^~/
    )

    match /log (on|off)/, method: :log_toggle
    def log_toggle(m)
      return unless authenticated? m

    end

    private
    def getuser(m)
      ZUser.where(nick: m.user.nick).first || ZUser.new
    end


  end
end