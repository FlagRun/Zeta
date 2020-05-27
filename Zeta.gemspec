# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'Zeta/version'

Gem::Specification.new do |spec|
  spec.name          = "zetabot"
  spec.version       = Zeta::VERSION
  spec.authors       = ["Liothen"]
  spec.email         = ["liothen@flagrun.net"]

  spec.summary       = %q{Zeta is a IRC bot written in ruby using the Cinch Framework}
  # spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "https://github.com/flagrun/Zeta"
  spec.license       = "MIT"
  spec.bindir        = 'bin'
  spec.executables   = %w{zetabot}

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "irbtools"

  spec.add_dependency 'daemons'
  spec.add_dependency 'destructor'
  spec.add_dependency 'tzinfo'
  spec.add_dependency 'unitwise'

  spec.add_dependency 'cinch'
  spec.add_dependency 'cinch-cooldown'
  spec.add_dependency 'cinch-toolbox'
  spec.add_dependency 'cinch-quotes'

  spec.add_dependency 'mkfifo'
  spec.add_dependency 'nokogiri'
  spec.add_dependency 'dronebl.rb'
  spec.add_dependency 'dnsbl-client'

  spec.add_dependency 'chronic'
  spec.add_dependency 'chronic_duration'
  spec.add_dependency 'tag_formatter'
  spec.add_dependency 'geocoder'
  spec.add_dependency 'httparty'
  spec.add_dependency 'rest-client'
  spec.add_dependency 'haml'
  spec.add_dependency 'actionview'
  spec.add_dependency 'persist'
  spec.add_dependency 'mechanize'

  spec.add_dependency 'recursive-open-struct'
  spec.add_dependency 'hashie'
  spec.add_dependency 'pdf-reader'
  spec.add_dependency 'faraday'
  spec.add_dependency 'humanize-bytes'
  spec.add_dependency 'crack'
  spec.add_dependency 'ipaddress'

  # API
  spec.add_dependency 'wolfram'
  spec.add_dependency 'wolfram-alpha'
  spec.add_dependency 'github_api'
  spec.add_dependency 'gist'
  spec.add_dependency 'discourse_api'
  spec.add_dependency 'video_info'
end
