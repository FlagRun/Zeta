def load_locale(file)
  YAML::load_file(File.join($root_path, 'locales', Zconf.locale, "/#{file}.yml"))
end