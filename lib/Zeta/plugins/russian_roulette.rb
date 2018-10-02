module Plugins
  class RussianRoulette
    include Cinch::Plugin
    include Cinch::Helpers
    enable_acl

    set plugin_name: "Russian Roulette",
        help: "In Soviet Russia, boolet shoots YOU!\nUsage: ?rr <nick>",
        react_on: :channel

    attr_reader :games

    PHRASES = [
        "\"BANG\" You're dead! ... Just kidding comrade... for now.",
        "\"...BLAMMO!\" (hangfires are a bitch, aren't they?)",
        "Are you scared yet, comrade?",
        "Are you pissing your pants yet?",
        "You are lucky, comrade. At least for now.",
        "The chamber was as empty as your head.",
        "Damn. And I thought that it had bullet too.",
        "Lucky you, comrade.",
        "Must be your lucky day, comrade.",
        "\"BLAM!\" you can't play russian roulette with a tokarev, comrade.",
        "... Looks like you get to live another day... or 5 second.",
        "... Bad primer."
    ]

    def initialize(*args)
      super
      @games = []
    end

    # match /rr(?: (.+))?/, method: :russian
    match 'rr', method: :russian

    def russian(m)
      return m.reply "I am sorry comrade, but I do not have pistol on me." unless m.channel.ops.include?(@bot)
      return m.user.notice "Sorry comrade, but there is already game going on." if @games.include?(m.channel.name)

      # player zeta_setup
      player = m.user
      # player = m.user if player == @bot
      # be nice, don't force the game on the starter unless the user actually exists in the channel.
      # return m.reply "I am terribly sorry %s, but I don't know %s." % [m.user.nick, player.nick] unless m.channel.users.include?(player)

      # start game
      @games << m.channel.name

      turns, round_location = Array.new(2) { |i| Random.new.rand(1..6) }
      m.channel.action "takes #{player.nick} into the back room for a #{turns} turn game"
      m.action_reply "pulls out her pistol"
      # m.channel.action "starts a %d-turn game of Russian Roulette with %s." % [turns, player.nick]

      phrases = PHRASES.dup.shuffle

      sleep 5

      turns.times do |chamber|
        return end_game(m.channel, true) unless m.channel.users.include?(player)
        if round_location == chamber.succ
          player.notice "*click*"
          sleep 5
          m.channel.kick(player, "*BLAM*")
          m.channel.action "walks back into the room *Alone*"
          break
        else
          phrase = phrases.pop
          player.notice "*click* %s" % phrase
        end
        sleep 5
      end

      if turns < round_location
        m.channel.action "walks back into the room with #{player}"
        m.reply "Looks like you get to live another day."
        m.channel.voice(player) # Voice the player because they survived
      end

      sleep 1 if turns < round_location
      end_game(m.channel)
    end

    private

    def end_game(channel, premature=false)
      @games.delete channel.name
      channel.msg "Oh vell, it vas fun vhile it lasted." if premature
      sleep 1
      channel.action "holsters the pistol."
    end
  end
end


# AutoLoad
Bot.config.plugins.plugins.push Plugins::RussianRoulette

