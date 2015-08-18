# -*- coding: utf-8 -*-

require 'yaml'

module Plugins
  class Attack
    include Cinch::Plugin
    include Cinch::Helpers

    enable_acl

     set(
      plugin_name: 'Random Attacker',
      help: 'Attacks a user with a random attack.\nUsage: `?attack <nick or phrase>`; `<nick or phrase>` may be omitted for a random attack on a random nick.',
      react_on: :channel
     )

    def initialize(*args)
      @attackdict = []
      super
    end

    # Regex
    match /attack(?: (.+))?/, group: :attack

    # Methods
    def execute(m, target=nil)
      target = target.rstrip
      target = m.user.nick if !target.nil? && target.match(/(\bmy\b|\b#{@bot.nick}\S*\b|\b\S*self\b)/i)
      target.gsub(/(\bmy\b|\b#{@bot.nick}\S*\b|\b\S*self\b)/i,m.user.nick+"'s") if !target.nil?;
       populate_attacks!
       output = if target
        attack!(target.gsub(/\x03([0-9]{2}(,[0-9]{2})?)?/,''), m.user.nick)
      else
        random_attack!(m.channel.users, m.user.nick)
      end
      m.channel.action output
    end

    private
    def populate_attacks!
      @attackdict.replace load_locale('attack').map {|e| e.gsub(/<(\w+)>/, "%<#{'\1'.downcase}>s") }
    end

    def grab_random_nick(users)
      users.to_a.sample[0].nick;
    end

    def attack!(target, assailant)
      return nil if target.nil?;
      @attackdict.sample % {:target => target, :assailant => assailant, :bot => @bot.nick};
    end

    def random_attack!(targets, assailant)
      @attackdict.sample % {:target => grab_random_nick(targets), :assailant => assailant, :bot => @bot.nick};
    end
   end
end

# AutoLoad
Zeta.config.plugins.plugins.push Plugins::Attack