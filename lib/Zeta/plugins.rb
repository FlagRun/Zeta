module Plugins; end

# Load STDLib plugins
if Config.plugins.class == Array
  Config.plugins.each do |p|
    begin
      require File.join('Zeta', 'plugins', p.to_s)
    rescue => e
      puts e
      warn "## Unable to load plugin: #{p} ##"
    end
  end

end

## Load Custom Plugins
if Config.custom_plugins.class == Array
  Config.custom_plugins.each do |p|
    begin
      require File.join(Dir.home, '.zeta', 'plugins', p.to_s, "#{p.to_s}.rb")
    rescue => e
      puts e
      warn "## Unable to load Custom plugin: #{p} ##"
    end
  end

end