# frozen_string_literal: true

RSpec.describe Admin::Oper do
  it 'opers up with the configured credentials' do
    Config.oper_username = 'zeta'
    Config.oper_password = 's3cret'
    say 'opal', '.operup'
    expect(sent).to include('OPER zeta s3cret')
  end

  it 'does nothing without credentials' do
    say 'opal', '.operup'
    expect(sent.grep(/\AOPER/)).to be_empty
  end

  it 'needs both a username and a password' do
    Config.oper_username = 'zeta'
    say 'opal', '.operup'
    Config.oper_username = nil
    Config.oper_password = 's3cret'
    say 'opal', '.operup'
    expect(sent.grep(/\AOPER/)).to be_empty
  end

  it 'kills users' do
    say 'opal', '.kill bob being rude'
    expect(sent).to include('KILL bob being rude')
    expect(replies).to eq(['bob: has been killed by opal for being rude'])
  end

  it 'never kills other opers' do
    say 'opal', '.kill opal oops'
    expect(sent.grep(/\AKILL/)).to be_empty
  end

  it 'sets modes through OperServ' do
    say 'opal', '.omode +m'
    expect(messages_to('OperServ')).to eq(['MODE #test +m'])
  end

  it 'clears channels without killing itself' do
    say 'opal', '.clearchan #test yes'
    expect(messages_to('OperServ')).to eq(['mode #test +o Zeta', 'mode #test +mi'])
    expect(sent).to include('KILL bob This channel is being cleared')
    expect(sent).not_to include('KILL Zeta This channel is being cleared')
    expect(replies).to eq(['This channel is being cleared', '#test has been cleared, 8 clients killed'])
  end

  it 'joins the channel before clearing it' do
    say 'opal', '.clearchan #test yes'
    expect(sent.index('JOIN #test')).to be < sent.index('KILL bob This channel is being cleared')
  end

  it 'also accepts true as confirmation' do
    say 'opal', '.clearchan #test true'
    expect(sent.grep(/\AKILL/).size).to eq(8)
    expect(replies.last).to eq('#test has been cleared, 8 clients killed')
  end

  it 'requires confirmation to clear a channel' do
    say 'opal', '.clearchan #test no'
    expect(sent.grep(/\AKILL/)).to be_empty
  end

  it 'is restricted to IRC operators' do
    say 'adam', '.kill bob x'
    expect(sent.grep(/\AKILL/)).to be_empty
  end
end
