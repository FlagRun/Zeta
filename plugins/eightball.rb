module Plugins
  class Eightball
    include Cinch::Plugin
    include Cinch::Helpers

    enable_acl

    set(
        plugin_name: "8ball",
        help:     "The Magic 8ball has all the answers!\nUsage: `?8ball [question? <question? <...>>]`",
        react_on: :channel)

    # Variables
    @@eightball = [
        "It is certain",
        "It is decidedly so",
        "Without a doubt",
        "Yes - definitely",
        "You may rely on it",
        "As I see it, yes",
        "Most likely",
        "Outlook good",
        "Signs point to yes",
        "Yes",
        "Reply hazy, try again",
        "Ask again later",
        "Better not tell you now",
        "Cannot predict now",
        "Concentrate and ask again",
        "Don't count on it",
        "My reply is no",
        "My sources say no",
        "Outlook not so good",
        "Very doubtful"
    ]

    # Regex
    match /8ball (.+)/

    # Methods
    def shake!
      @@eightball.sample
    end

    def execute(m, s)
      m.safe_reply @@eightball.sample, true
    end

  end
end

# AutoLoad
Zeta.config.plugins.plugins.push Plugins::Eightball