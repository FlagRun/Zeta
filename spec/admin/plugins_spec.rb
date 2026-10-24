# frozen_string_literal: true

require_relative '../fixtures/plugins_probe/helper'

RSpec.describe Admin::Plugins do
  def hello_loaded? = Bot.plugins.any? { |p| p.instance_of?(Plugins::Hello) }

  after do
    Bot.plugins.register_plugin(Plugins::Hello) unless hello_loaded?
    Bot.config.plugins.options.delete(Plugins::Wikipedia)
    Bot.config.plugins.options.delete(Admin::Bot)
  end

  it 'unloads and loads custom plugins' do
    say 'opal', '.plugin unload Hello'
    expect(replies).to eq(['Successfully unloaded Hello'])
    expect(hello_loaded?).to be(false)
    say 'bob', '.hello'
    expect(replies.size).to eq(1)

    say 'opal', '.plugin load Hello'
    expect(replies.last).to eq('Successfully loaded Hello')
    say 'bob', '.hello'
    expect(replies.last).to eq('Hello, bob!')
    expect(Bot.plugins.count { |p| p.instance_of?(Plugins::Hello) }).to eq(1)
  end

  it 'reloads plugins' do
    say 'opal', '.plugin reload Hello'
    expect(replies).to eq(['Successfully unloaded Hello', 'Successfully loaded Hello'])
    say 'bob', '.hello'
    expect(replies).to eq(['Successfully unloaded Hello', 'Successfully loaded Hello', 'Hello, bob!'])
  end

  context 'when a plugin changes between reloads' do
    let(:probe_dir) { File.join(Dir.home, '.zeta', 'plugins', 'plugins_probe') }

    def install_probe(version)
      FileUtils.mkdir_p(probe_dir)
      FileUtils.cp(File.expand_path("../fixtures/plugins_probe/#{version}.rb", __dir__), File.join(probe_dir, 'plugins_probe.rb'))
    end

    def join(nick) = feed(":#{nick}!#{nick}@#{nick}.host JOIN #test")
    def ctcp_probe = pm('bob', "\u0001PROBE\u0001")
    def new_output = sent.drop(@mark)
    def mark! = @mark = sent.size

    after do
      Bot.plugins.select { |p| p.class.name == 'Plugins::PluginsProbe' }.each { |p| Bot.plugins.unregister_plugin(p) }
      Bot.config.plugins.options.delete(Plugins::PluginsProbe) if defined?(Plugins::PluginsProbe)
      FileUtils.rm_rf(probe_dir)
    end

    it 'drops every class-level setting of the old version' do
      install_probe('v1')
      say 'opal', '.plugin load PluginsProbe'
      expect(replies).to eq(['Successfully loaded PluginsProbe'])

      mark!
      say 'bob', '!probe?'
      say 'carol', '!probe?'
      pm 'bob', '!probe?'
      join 'dave'
      ctcp_probe
      say 'bob', '!help probeone?'
      expect(new_output).to eq(['PRIVMSG #test :probe v1', 'PRIVMSG #test :welcome dave',
                                "NOTICE bob :\u0001PROBE probe v1\u0001", 'PRIVMSG #test :probe v1 help'])
      expect(plugin(Plugins::PluginsProbe).timers.size).to eq(1)

      install_probe('v2')
      say 'opal', '.plugin reload PluginsProbe'
      expect(replies.last(2)).to eq(['Successfully unloaded PluginsProbe', 'Successfully loaded PluginsProbe'])

      mark!
      say 'bob', '.probe'
      say 'carol', '.probe'
      pm 'bob', '.probe'
      join 'erin'
      ctcp_probe
      say 'bob', '.help probeone'
      say 'bob', '.help pluginsprobe'
      expect(new_output.grep(/\APRIVMSG|\ANOTICE bob :\u0001/)).to eq(
        ['PRIVMSG #test :probe v2', 'PRIVMSG #test :probe v2', 'PRIVMSG bob :probe v2', 'PRIVMSG #test :probe v2 help']
      )
      # Timers only start on :connect, so check that none was carried over.
      expect(plugin(Plugins::PluginsProbe).timers).to be_empty

      install_probe('v3')
      say 'opal', '.plugin reload PluginsProbe'
      mark!
      say 'bob', '.help pluginsprobe'
      say 'bob', '.probe'
      expect(new_output.grep(/\APRIVMSG/)).to eq(['PRIVMSG #test :probe v3'])
    end
  end

  it 'finds bundled plugins in the stdlib plugin directory' do
    say 'opal', '.plugin load Eightball'
    expect(replies).to eq(['Eightball is already loaded.'])
  end

  it 'only treats Cinch plugin classes inside the Plugins namespace as plugins' do
    say 'opal', '.plugin unload PluginsProbeHelper'
    say 'opal', '.plugin set Admin::Bot foo 1'
    expect(replies).to eq(['Could not unload PluginsProbeHelper because no matching class was found.',
                           'Could not set plugin option for Admin::Bot because no matching class was found.'])
    expect(Bot.config.plugins.options).not_to have_key(Admin::Bot)
  end

  it 'requires admin status in the secure channel' do
    say 'adam', '.plugin set Nope foo 1'
    expect(replies).to be_empty

    IrcHarness.sync_channel!('#secure', '@Zeta &adam')
    say 'adam', '.plugin set Nope foo 1'
    expect(replies).to eq(['Could not set plugin option for Nope because no matching class was found.'])
  end

  it 'refuses to load a plugin twice' do
    say 'opal', '.plugin load Hello'
    expect(replies).to eq(['Hello is already loaded.'])
  end

  it 'reports missing plugin files' do
    say 'opal', '.plugin load NoSuchThing'
    expect(replies).to eq(['Could not load NoSuchThing because no_such_thing.rb does not exist.'])
  end

  it 'refuses file mappings that could escape the plugin directories' do
    loaded = []
    without_partial_double_verification do
      allow_any_instance_of(Admin::Plugins).to receive(:load) { |_, f| loaded << f }
    end
    say 'opal', '.plugin load Evil ../../../tmp/evil'
    expect(replies).to eq(['Could not load Evil because ../../../tmp/evil is not a valid plugin name.'])
    expect(loaded).to be_empty
  end

  it 'reports unknown plugins when unloading' do
    say 'opal', '.plugin unload String'
    expect(replies).to eq(['Could not unload String because no matching class was found.'])
  end

  it 'sets plugin options' do
    say 'opal', '.plugin set Wikipedia max_length 50'
    expect(Bot.config.plugins.options[Plugins::Wikipedia]).to eq(max_length: 50)
  end

  it 'reports unknown plugins when setting options without evaluating the value' do
    say 'opal', '.plugin set Nope foo $zeta_plugins_probe = :evaluated'
    expect(replies).to eq(['Could not set plugin option for Nope because no matching class was found.'])
    expect($zeta_plugins_probe).to be_nil
  ensure
    $zeta_plugins_probe = nil
  end

  it 'is not available to regular users' do
    say 'bob', '.plugin unload Hello'
    expect(replies).to be_empty
    expect(hello_loaded?).to be(true)
  end
end
