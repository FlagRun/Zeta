module Admin
  class BotEval
    include Cinch::Plugin
    include Cinch::Helpers

    enable_acl(:owner)

    set(
        plugin_name: "BotEval",
        help:        "Bot administrator-only private commands.\nUsage: `?er <code>`;",
    )

    # Regex
    match /e (.+)/, method: :boteval
    match /eval (.+)/, method: :boteval
    match /ereturn (.+)/, method: :botevalreturn
    match /er (.+)/, method: :botevalreturn
    match /evalmsg (.+)/, method: :botevalmsg
    match /em (.+)/, method: :botevalmsg

    def boteval(m, s)
      eval(s)
    rescue => e
      m.user.send "eval error: %s\n- %s (%s)" % [s, e.message, e.class.name]
    end

    def botevalreturn(m, s)
      return m.reply eval(s)
    rescue => e
      m.user.send "eval error: %s\n- %s (%s)" % [s, e.message, e.class.name]
    end

    def botevalmsg(m, s)
      return m.user.msg eval(s)
    rescue => e
      m.user.send "eval error: %s\n- %s (%s)" % [s, e.message, e.class.name]
    end

  end
end


# AutoLoad
Zeta.config.plugins.plugins.push Admin::BotEval