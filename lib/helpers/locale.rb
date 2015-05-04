def load_locale(file)
  Zconf.locale ||= 'en'
  YAML::load_file(File.join($root_path, 'locales', Zconf.locale, "/#{file}.yml"))
end