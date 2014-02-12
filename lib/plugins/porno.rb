require 'yaml'


module Plugins
  class Porno
    include Cinch::Plugin

    set help: "Random porno film names.\nUsage: `!porno [search term]`",
        prefix: /^./

    match /porno(?> )?(.+)?/, method: :execute_porno

    def execute_porno(m, search)

      pornos = YAML.load_file(File.join(__dir__, '../locales/porno.yml'))
      if search
        results = pornos.find_all { |title| title =~ /#{Regexp.escape(search)}/i }
        m.reply (results.empty? ? pornos : results).sample, true
      else
        m.reply pornos.sample, true
      end
    end
  end
end