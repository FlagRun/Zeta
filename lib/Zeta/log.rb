Bot.loggers << Cinch::Logger::FormattedLogger.new(File.open(File.join(Dir.home, '.zeta', 'log', 'error.log'), 'a'))
Bot.loggers.last.level = :error