# frozen_string_literal: true

RSpec.describe Zeta do
  it 'has a semantic version number' do
    expect(Zeta::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end

  describe 'configuration' do
    it 'loads ~/.zeta/config.rb into Config' do
      expect(Config.nickname).to eq('Zeta')
      expect(Config.secrets[:omdb]).to eq('omdb-key')
    end

    it 'configures the Cinch bot from Config' do
      expect(Bot.config.nick).to eq('Zeta')
      expect(Bot.config.nicks).to eq(['Zeta'])
      expect(Bot.config.user).to eq('zeta')
      expect(Bot.config.server).to eq('127.0.0.1')
      expect(Bot.config.channels).to eq(['#test'])
      expect(Bot.config.plugins.prefix).to eq(/^\./)
    end

    it 'writes a log file to ~/.zeta/log' do
      expect(File).to exist(File.join(Dir.home, '.zeta', 'log', 'error.log'))
    end
  end

  describe 'plugin loading' do
    let(:loaded) { Bot.plugins.map(&:class) }

    it 'registers every admin plugin' do
      expect(loaded).to include(Admin::Autojoin, Admin::AutoVoice, Admin::Blacklister, Admin::Bot,
                                Admin::Channels, Admin::Eval, Admin::Fifo, Admin::Ignore, Admin::Oper,
                                Admin::Plugins)
    end

    it 'registers every configured bundled plugin' do
      expect(loaded).to include(
        Plugins::Attack, Plugins::BotInfo, Plugins::DarkScience, Plugins::DBZ, Plugins::DNSBlacklist,
        Plugins::Eightball, Plugins::Fml, Plugins::Fnord, Plugins::Gif, Plugins::BotHelp, Plugins::Macros,
        Plugins::Movie, Plugins::Noticeme, Plugins::PDFinfo, Plugins::Rainbow, Plugins::RussianRoulette,
        Plugins::Seen, Plugins::Silly, Plugins::Snooper, Plugins::UrbanDictionary, Plugins::Weather,
        Plugins::Wikipedia, Plugins::Wolfram
      )
    end

    it 'loads custom plugins from ~/.zeta/plugins' do
      expect(loaded).to include(Plugins::Hello)
      say 'bob', '.hello'
      expect(replies).to eq(['Hello, bob!'])
    end

    it 'registers each plugin only once' do
      expect(loaded.tally.values.uniq).to eq([1])
    end
  end

  describe 'Ruby 4 compatibility' do
    lib = File.expand_path('../lib', __dir__)
    sources = Dir[File.join(lib, '**', '*.rb')].to_h { |f| [f.delete_prefix("#{lib}/"), File.read(f)] }

    {
      'File.exists?' => /File\.exists\?/,
      'URI.escape' => /URI\.escape\b/,
      'Kernel#open on a URL' => /(?<![.\w])open\(\s*(url|['"]https?:)/
    }.each do |api, pattern|
      it "does not use removed API #{api}" do
        offenders = sources.select { |_, src| src.lines.reject { |l| l.strip.start_with?('#') }.join.match?(pattern) }
        expect(offenders.keys).to be_empty
      end
    end
  end
end
