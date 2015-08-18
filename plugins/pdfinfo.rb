require 'faraday'
require 'open-uri'
require 'action_view'
require 'pdf-reader'
require 'humanize-bytes'

module Plugins
  class PDFinfo
    include Cinch::Plugin
    include Cinch::Helpers
    include ActionView::Helpers::DateHelper

    enable_acl

    self.plugin_name = 'PDF Information'
    self.help = 'This plugin will check a url for a pdf link and fetch metadata from it'


    # Default list of URL regexps to ignore.
    DEFAULT_ALLOWED = [/\.pdf$/i].freeze
    FILE_SIZE_LIMIT = 4000000


    match %r{(https?://.*?)(?:\s|$|,|\.\s|\.$)}, :use_prefix => false

    def execute(msg, url)

      allowedlist = DEFAULT_ALLOWED.dup
      allowedlist.concat(config[:blacklist]) if config[:blacklist]

      return unless allowedlist.any? { |entry| url =~ entry }
      debug "URL matched: #{url}"

      # Grab header and check filesize
      # one line to make request
      head = Faraday.head url

      # example with headers
      file_size = head.headers['Content-Length']
      humanize_size = Humanize::Byte.new(file_size.to_i).to_k.to_s.to_i.round(2)
      if file_size.to_i > FILE_SIZE_LIMIT
        return msg.reply("PDF → Unable to parse. file too big #{humanize_size}kb")
      end


      # Get file and parse metadata
      open(url, "rb") do |io|
        reader = PDF::Reader.new(io)
        creator = reader.info[:Creator] || 'Anon'
        producer = reader.info[:Producer] || 'Anon'
        creation = reader.info[:CreationDate] || 'now'
        modification = reader.info[:ModDate] || 'now'
        title = reader.info[:Title] || nil
        display = title ? title : "Title: None <> Creator: #{creator} <> Producer: #{producer} <> Creation: #{creation}"
        msg.reply "PDF (#{humanize_size}kb) → #{display}"
      end


    rescue => e
      error "#{e.class.name}: #{e.message}"
    end


  end

end

# AutoLoad
Zeta.config.plugins.plugins.push Plugins::PDFinfo