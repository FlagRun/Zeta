def load_locale(file)
  Config.locale ||= 'en' # Default to english

  if File.exists?( File.join(Dir.home, '.zeta', 'locale', Config.locale, "#{file}.yml") )
    ## Overide included library if file exists
    YAML::load_file(
        File.join(Dir.home, '.zeta', 'locale', Config.locale, "#{file}.yml")
    )
  else
    YAML::load_file(
        File.join(File.dirname(__FILE__), 'locale', Config.locale, "#{file}.yml")
    )

  end


end