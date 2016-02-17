def load_locale(file)
  Config.locale ||= 'en'
  # YAML::load_file(File.join('lib', 'Zeta', 'locale', Config.locale, "#{file}.yml"))
  YAML::load_file(
      File.join(File.dirname(__FILE__), 'locale', Config.locale, "#{file}.yml")
  )
end