# frozen_string_literal: true

RSpec.describe Admin::Plugins do
  def hello_loaded? = Bot.plugins.any? { |p| p.instance_of?(Plugins::Hello) }

  after do
    Bot.plugins.register_plugin(Plugins::Hello) unless hello_loaded?
    Bot.config.plugins.options.delete(Plugins::Wikipedia)
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
    expect(replies.last).to eq('Hello, bob!')
  end

  it 'refuses to load a plugin twice' do
    say 'opal', '.plugin load Hello'
    expect(replies).to eq(['Hello is already loaded.'])
  end

  it 'reports missing plugin files' do
    say 'opal', '.plugin load NoSuchThing'
    expect(replies).to eq(['Could not load NoSuchThing because no_such_thing.rb does not exist.'])
  end

  it 'reports unknown plugins when unloading' do
    say 'opal', '.plugin unload String'
    expect(replies).to eq(['Could not unload String because no matching class was found.'])
  end

  it 'sets plugin options' do
    say 'opal', '.plugin set Wikipedia max_length 50'
    expect(Bot.config.plugins.options[Plugins::Wikipedia]).to eq(max_length: 50)
  end

  it 'reports unknown plugins when setting options' do
    say 'opal', '.plugin set Nope foo 1'
    expect(replies).to eq(['Could not set plugin option for Nope because no matching class was found.'])
  end

  it 'is not available to regular users' do
    say 'bob', '.plugin unload Hello'
    expect(replies).to be_empty
    expect(hello_loaded?).to be(true)
  end
end
