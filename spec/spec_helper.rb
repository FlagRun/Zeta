# frozen_string_literal: true

# Zeta reads its configuration from ~/.zeta at require time, so the bot is
# booted once against a throw-away HOME before any spec runs.
require 'tmpdir'
require 'fileutils'
require 'stringio'

ENV['TZ'] = 'UTC' # date based plugins use the local clock
ZETA_TEST_HOME = Dir.mktmpdir('zeta-spec-home')
ENV['HOME'] = ZETA_TEST_HOME
%w[cache log plugins locale].each { |d| FileUtils.mkdir_p(File.join(ZETA_TEST_HOME, '.zeta', d)) }
FileUtils.cp_r(File.expand_path('fixtures/plugins/hello', __dir__), File.join(ZETA_TEST_HOME, '.zeta', 'plugins'))
FileUtils.cp(File.expand_path('fixtures/config.rb', __dir__), File.join(ZETA_TEST_HOME, '.zeta', 'config.rb'))

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'webmock/rspec'

# Cinch's default logger captures $stderr when the bot is created.
original_stderr = $stderr
$stderr = StringIO.new
begin
  require 'Zeta'
ensure
  $stderr = original_stderr
end

require 'active_support/testing/time_helpers'
require_relative 'support/irc_harness'

IrcHarness.boot!

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.disable_monkey_patching!
  config.order = :random
  Kernel.srand config.seed

  config.include IrcHarness::Helpers
  config.include ActiveSupport::Testing::TimeHelpers

  config.before do |example|
    IrcHarness.reset!
    # Snooper reacts to anything that looks like a URL; keep it quiet unless under test.
    unless example.metadata[:snooper]
      without_partial_double_verification { allow(plugin(Plugins::Snooper)).to receive(:execute) }
    end
  end

  config.after do |example|
    # Cinch logs any exception raised inside a handler thread; fail loudly on it.
    unless example.metadata[:allow_errors] || example.exception
      expect(IrcHarness.error_log).to eq(''), "handler logged errors:\n#{IrcHarness.error_log}"
    end
  end

  config.after(:suite) do
    FileUtils.rm_rf(ZETA_TEST_HOME)
  end
end
