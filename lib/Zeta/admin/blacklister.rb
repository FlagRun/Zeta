module Admin
  class Blacklister
    include Cinch::Plugin

    enable_acl(:oper)

    set(
        plugin_name: "Bot_Eval",
        help:        "Bot administrator-only private commands.\nUsage: `?er <code>`;",
    )

    # Regex
    match /bl channel (\S+)/, method: :bl_channel
    match /bl url (\S+)/, method: :bl_url
    match /bl mask (\S+)/, method: :bl_mask
    # match /bl plugin (\S+)/, method: :bl_plugin

    # Load the defaults
    match 'bl defaults', method: :bl_defaults

    # Sync
    match 'sync', method: :sync
    match 'bl sync', method: :sync


    def bl_channel(m, chan)
      m.reply "#{chan} is already on BlackList" if Blacklist.channels.include? chan
      Blacklist.channels << chan
      save_blacklist()
      m.reply "#{chan} is now on the BlackList"
    end

    def bl_url(m, url)
      m.reply "#{url} is already on BlackList" if Blacklist.channels.include? url
      Blacklist.urls << url
      save_blacklist()
      m.reply "#{url} is now on the BlackList"
    end

    def bl_mask(m, mask)
      m.reply "#{mask} is already on BlackList" if Blacklist.masks.include? mask
      Blacklist.masks << url
      save_blacklist()
      m.reply "#{mask} is now on the BlackList"
    end

    def bl_plugin(m, plugin)
      # TODO: This needs alot more work because i need to disable by channel
    end

    def bl_defaults(m)
      clear_blacklist()
      Blacklist.urls = Config.options[:blacklist][:urls]
      Blacklist.users = Config.options[:blacklist][:users]
      Blacklist.masks = Config.options[:blacklist][:masks]
      Blacklist.channels = Config.options[:blacklist][:channels]
      save_blacklist()
      m.reply 'Default Blacklist Loaded'
    end

    def sync(m)
      save_blacklist()
      m.action_reply 'Blacklist is now synced!'
    end



  end
end


# AutoLoad
Bot.config.plugins.plugins.push Admin::Blacklister