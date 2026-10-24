module Admin
  class Plugins
    include Cinch::Plugin
    include Cinch::Helpers

    enable_acl(:admin, true)

    set(
        plugin_name: 'PluginsAdmin',
        help: "Bot administrator-only private commands.\nUsage: `~join [channel]`; `~part [channel] <reason>`; `~quit [reason]`;",
    # prefix: /^\?/
    )

    # Regex
    match(/plugin load (\S+)(?: (\S+))?/, method: :load_plugin)
    match(/plugin unload (\S+)/, method: :unload_plugin)
    match(/plugin reload (\S+)(?: (\S+))?/, method: :reload_plugin)
    match(/plugin set (\S+) (\S+) (.+)$/, method: :set_option)

    # Methods
    def load_plugin(m, plugin, mapping)
      mapping ||= plugin.gsub(/(.)([A-Z])/) { |_|
        $1 + "_" + $2
      }.downcase # we downcase here to also catch the first letter

      custom_plugin = File.join(Dir.home, '.zeta', 'plugins', mapping, "#{mapping}.rb")
      stdlib_plugin = File.expand_path(File.join('..', 'plugins', "#{mapping}.rb"), __dir__)
      file_name = [custom_plugin, stdlib_plugin].find { |f| File.exist?(f) }

      unless file_name
        m.reply "Could not load #{plugin} because #{mapping}.rb does not exist."
        return
      end

      existing = plugin_class(plugin)
      if existing && @bot.plugins.any? { |p| p.instance_of?(existing) }
        m.reply "#{plugin} is already loaded."
        return
      end

      begin
        load(file_name)
      rescue StandardError, ScriptError
        m.reply "Could not load #{plugin}."
        raise
      end

      const = plugin_class(plugin)
      unless const
        m.reply "Could not load #{plugin} because no matching class was found."
        return
      end

      @bot.plugins.register_plugin(const)
      m.reply "Successfully loaded #{plugin}"
    end

    def unload_plugin(m, plugin)
      plugin_class = plugin_class(plugin)
      unless plugin_class
        m.reply "Could not unload #{plugin} because no matching class was found."
        return
      end

      @bot.plugins.select { |p| p.class == plugin_class }.each do |p|
        @bot.plugins.unregister_plugin(p)
      end

      ## FIXME not doing this at the moment because it'll break
      ## plugin options. This means, however, that reloading a
      ## plugin is relatively dirty: old methods will not be removed
      ## but only overwritten by new ones. You will also not be able
      ## to change a classes superclass this way.
      # Cinch::Plugins.__send__(:remove_const, plugin)

      # Because we're not completely removing the plugin class,
      # reset everything to the starting values.
      plugin_class.hooks.clear
      plugin_class.matchers.clear
      plugin_class.listeners.clear
      plugin_class.timers.clear
      plugin_class.ctcps.clear
      plugin_class.react_on = :message
      plugin_class.plugin_name = nil
      plugin_class.help = nil
      plugin_class.prefix = nil
      plugin_class.suffix = nil
      plugin_class.required_options.clear

      m.reply "Successfully unloaded #{plugin}"
    end

    def reload_plugin(m, plugin, mapping)
      unload_plugin(m, plugin)
      load_plugin(m, plugin, mapping)
    end

    def set_option(m, plugin, option, value)
      const = plugin_class(plugin)
      unless const
        m.reply "Could not set plugin option for #{plugin} because no matching class was found."
        return
      end
      @bot.config.plugins.options[const][option.to_sym] = eval(value)
    end

    private

    # Bare `Plugins` here would resolve to this class, not the ::Plugins namespace.
    def plugin_class(name)
      const = ::Plugins.const_get(name, false)
      const if const.is_a?(Class) && const.include?(Cinch::Plugin)
    rescue NameError
      nil
    end
  end

end


# AutoLoad
Bot.config.plugins.plugins.push Admin::Plugins