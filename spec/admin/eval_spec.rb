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

  it 'accepts the short .e and long .evalmsg forms' do
    say 'opal', '.e $zeta_eval_probe = :short'
    expect($zeta_eval_probe).to eq(:short)
    say 'opal', '.evalmsg 2 + 2'
    expect(messages_to('opal')).to eq(['4'])
  ensure
    $zeta_eval_probe = nil
  end

  it 'is disabled unless Config.debug is set' do
    Config.debug = false
    say 'opal', '.er 6 * 7'
    say 'opal', '.eval $zeta_eval_probe = :ran'
    say 'opal', '.em 1 + 1'
    expect($zeta_eval_probe).to be_nil
    expect(replies).to be_empty
    expect(messages_to('opal')).to be_empty
  ensure
    $zeta_eval_probe = nil
  end

  it 'is restricted to IRC operators' do
    say 'adam', '.er 6 * 7'
    expect(replies).to be_empty
  end
end
