ConfigStruct = Struct.new(
                         :locale,
                         :nickname,
                         :nicks,
                         :username,
                         :realname,
                         :prefix,
                         :server,
                         :password,
                         :port,
                         :ssl,
                         :sasl_username,
                         :sasl_password,
                         :max_messages,
                         :messages_per_second,
                         :modes,
                         :channels,
                         :custom_plugins,
                         :plugins,
                         :oper_username,
                         :oper_password,
                         :oper_overide,
                         :log_channel,
                         :services,
                         :secure_mode,
                         :secure_channel,
                         :secure_host,
                         :options,
                         :debug,
                         :secrets
)
# Initialize Config
Config = ConfigStruct.new

if File.exists? File.join(Dir.home, '.zeta', 'config.rb')
  begin
    require File.join(Dir.home, '.zeta', 'config.rb')
  rescue => e
    puts e
    abort('Unable to read config')
  end

end