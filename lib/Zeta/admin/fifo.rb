unless defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby'
  require 'mkfifo'
end

# Named pipe plugin for Cinch.
module Admin
  class Fifo
    include Cinch::Plugin
    listen_to :connect, :method => :open_fifo
    listen_to :disconnect, :method => :close_fifo

    def open_fifo(m)
      # Sometimes FiFo is left open on crash, remove old fifo
      if File.exists?(File.join(Dir.home, '.zeta', 'zeta.io'))
        File.delete(File.join(Dir.home, '.zeta', 'zeta.io'))
      end

      File.mkfifo(File.join(Dir.home, '.zeta', 'zeta.io') || raise(ArgumentError, "No FIFO path given!"))
      File.chmod(0660, File.join(Dir.home, '.zeta', 'zeta.io'))

      File.open(File.join(Dir.home, '.zeta', 'zeta.io'), "r+") do |fifo|
        bot.info "Opened named pipe (FIFO) at #{File.join(Dir.home, '.zeta', 'zeta.io')}"

        fifo.each_line do |line|
          msg = line.strip
          bot.debug "Got message from the FIFO: #{msg}"
          bot.irc.send msg
        end
      end

    end

    def close_fifo(msg)
      File.delete(File.join(Dir.home, '.zeta', 'zeta.io'))
      bot.info "Deleted named pipe #{File.join(Dir.home, '.zeta', 'zeta.io')}"
    end

  end
end


# AutoLoad if Not Jruby
unless defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby'
  Bot.config.plugins.plugins.push Admin::Fifo
end