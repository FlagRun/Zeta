require 'cinch'
module Plugins
  class PluginManager
    include Cinch::Plugin
    @plugin="pluginmanager"
    @help="pluginmanager: pluginmanager load|unload plugin - (re)load|unload target plugin"

    def initialize(*args)
      super
      @plugdir = Dir.pwd+"/plugins"
    end

    hook :pre, method: :update_plug_list

    def update_plug_list(m)
      @plugins = bot.plugins
    end

    match /pluginmanager load (.+)/, method: :load
    def load(m, plugin)
      if getuser(m).is_admin?
        unload(m, plugin)
        Dir.foreach(@plugdir) do |plugf|
          if plugf.split(".")[0] == pluging
            if not defined? plugin.capitalize
              require @plugdir+"/#{plugin}"
            end
            begin
              bot.plugins.register_plugin(my_constantize(plugin).new(bot))
            rescue NameError
              m.reply "Not a valid plugin name"
            end
            break
          end
        end
      end
    end

    match /pluginmanager unload (.+)/, method: :unload

    def unload(m, plugin)
      if getuser(m).is_admin?
        @plugins.each do |plug|
          if plug.plugin_name == plugin
            bot.plugins.unregister_plugin(plug)
            break
          end
        end
      end
    end

    # helper to dynamically require and create plugins. totally bad juju
    def my_constantize(class_name)
      unless /\A(?:::)?([A-Z]\w*(?:::[A-Z]\w*)*)\z/ =~ class_name
        raise NameError, "#{class_name.inspect} is not a valid constant name!"
      end
      Object.module_eval("::#{$1}", __FILE__, __LINE__)
    end

    private
    def getuser(m)
      ZUser.where(nick: m.user.nick).first || ZUser.new
    end
  end

end
