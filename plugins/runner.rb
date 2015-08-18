require 'evalso'
require 'gist'

class Plugins::Runner
  include Cinch::Plugin
  include Cinch::Helpers

  enable_acl

  set(
      plugin_name: "Runner",
      help: "Run a program though eval.so!\nUsage: `?run [lang] <expression>` `?langs`",
  )

  match /run ([\S]+) (.+)/, method: :eval
  match /r ([\S]+) (.+)/, method: :eval
  match /runner ([\S]+) (.+)/, method: :eval
  match /langs/, method: :langs


  # Print out a list of languages
  # Params:
  # +m+:: +Cinch::Message+ object
  def langs(m)
    m.safe_reply "Available languages: #{Evalso.languages.keys.join(', ')}"
  end

  # Evaluate code using the eval.so API
  # Params:
  # +m+:: +Cinch::Message+ object
  # +lang+:: The language for code to be evaluated with
  # +code+:: The code to be evaluated
  def eval(m, lang, code)
    res = Evalso.run(language: lang, code: code)
    # Default to stdout, fall back to stderr.
    output = res.stdout
    output = res.stderr if output.empty?
    output = output.gsub(/\n/, ' ')
    # According to RFC 2812, the maximum command length on IRC is 512 characters.
    # This makes our maximum message length 512 - '\r\n'.length - the header information
    # In order to not spam the channel, if the output is greater than one line, convert it to a gist
    maxlength = 510 - (":" + " PRIVMSG " + " :").length - @bot.mask.to_s.length - m.target.name.length
    maxlength = maxlength - ("#{m.user.name}: ").length if m.target.is_a? Cinch::Channel
    if output.length > maxlength
      output = Gist.gist(output, filename: 'result', description: code)['html_url']
    end
    m.safe_reply output, true
  rescue Evalso::HTTPError => e
    # Eval.so returned an error, pass it on to IRC.
    m.safe_reply "Error: #{e.message}", true
  end
end


# AutoLoad
Zeta.config.plugins.plugins.push Plugins::Runner