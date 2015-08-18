# -*- coding: utf-8 -*-
require 'tag_formatter'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/array/conversions'
require 'chronic_duration'


module Plugins
  class BotInfo
    include Cinch::Plugin
    include Cinch::Helpers

    enable_acl

    set(
      plugin_name: "Botinfo",
      help: "Notices you information about me.\nUsage: `/msg <nick> info`\nUsage: `/msg <nick> list plugins`",
      react_on: :private)

    def initialize *args
      super
      @started_at = Time.now
    end

    # How to config:
    # :template -- a path to a textual file (such as *.txt) with fields in it.
    # :owner -- What to display for the "owner_name" field.
    # All fields in the text file must be surrounded by '<>', and lines can be commented out using '#'.

    # Regex
    match 'info', use_prefix: false
    match 'list plugins', method: :execute_list, use_prefix: false
    match /^help (.+)$/i, method: :execute_help, use_prefix: false

    # Methods
    def execute(m)
      tags = {
        bot_name: @bot.nick,
        cinch_version: Cinch::VERSION,
        #is_admin: config[:admins].is_admin?(m.user.mask) ? "an admin" : "not an admin",
        owner_name: 'Liothen',
        plugins_count_remaining: @bot.plugins.length - 10,
        plugins_head: @bot.plugins[0..9].map {|p| p.class.plugin_name }.join(", "),
        ruby_platform: RUBY_PLATFORM,
        ruby_release_date: RUBY_RELEASE_DATE,
        ruby_version: RUBY_VERSION,
        session_start_date: @started_at.strftime("%A, %B %e, %Y, at %l:%M:%S %P"),
        total_channels: @bot.channels.length,
        total_users: proc {
          users = [];
          @bot.channels.each {|c|
              c.users.each {|u| users << u[0].nick
            }
          };
          users.uniq.size
        }.call,
        uptime: ChronicDuration.output(Time.now.to_i - @started_at.to_i)
      }

      tf = TagFormatter.new open(File.join(__dir__, '../botinfo.txt'),&:read), tags: tags

      m.user.notice tf.parse
    end

    def execute_list(m)

      list = []
      @bot.plugins.each {|p| list << p.class.plugin_name };
      m.user.notice("All #{list.size} currently loaded plugins for #{@bot.nick}:\n#{list.to_sentence}.\nTo view help for a plugin, use `/msg #{@bot.nick} help <plugin name>`.")
    end

    def execute_help(m, name)
      list = {}
      @bot.plugins.each {|p| list[p.class.plugin_name.downcase] = {name: p.class.plugin_name, help: p.class.help} };
      return m.user.notice("Help for \"#{name}\" could not be found.") if !list.has_key?(name.downcase)
      m.user.notice("Help for #{Format(:bold,list[name.downcase][:name])}:\n#{list[name.downcase][:help]}")
    end

  end
end

# AutoLoad
Zeta.config.plugins.plugins.push Plugins::BotInfo