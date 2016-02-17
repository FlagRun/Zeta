def load_locale(file)
  Config.locale ||= 'en'
  YAML::load_file(File.join('locale', Config.locale, "#{file}.yml"))
end