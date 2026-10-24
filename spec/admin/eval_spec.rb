# frozen_string_literal: true

RSpec.describe Admin::Eval do
  before { Config.debug = true }

  it 'evaluates and replies for opers' do
    say 'opal', '.er 6 * 7'
    expect(replies).to eq(['42'])
  end

  it 'evaluates silently' do
    say 'opal', '.eval $zeta_eval_probe = :ran'
    expect($zeta_eval_probe).to eq(:ran)
    expect(replies).to be_empty
  ensure
    $zeta_eval_probe = nil
  end

  it 'messages the result to the user' do
    say 'opal', '.em 1 + 1'
    expect(messages_to('opal')).to eq(['2'])
  end

  it 'reports errors privately' do
    say 'opal', ".ereturn raise 'boom'"
    expect(messages_to('opal')).to eq(["eval error: raise 'boom'", '- boom (RuntimeError)'])
  end

  it 'is disabled unless Config.debug is set' do
    Config.debug = false
    say 'opal', '.er 6 * 7'
    expect(replies).to be_empty
  end

  it 'is restricted to IRC operators' do
    say 'adam', '.er 6 * 7'
    expect(replies).to be_empty
  end
end
