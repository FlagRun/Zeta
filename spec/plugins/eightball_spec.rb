# frozen_string_literal: true

RSpec.describe Plugins::Eightball do
  let(:answers) { described_class.class_variable_get(:@@eightball) }

  it 'answers a question with a prefixed 8ball response' do
    say 'bob', '.8ball will the tests pass?'
    expect(replies.size).to eq(1)
    expect(replies.first).to start_with('bob: ')
    expect(answers).to include(replies.first.delete_prefix('bob: '))
  end

  it 'ignores private messages' do
    pm 'bob', '.8ball hello?'
    expect(sent.grep(/PRIVMSG/)).to be_empty
  end

  it 'requires a question' do
    say 'bob', '.8ball'
    expect(replies).to be_empty
  end
end
