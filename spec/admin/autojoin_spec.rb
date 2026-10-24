# frozen_string_literal: true

RSpec.describe Admin::Autojoin do
  it 'joins on invite and logs it' do
    feed ':carol!carol@carol.host INVITE Zeta :#fun'
    expect(sent).to include('JOIN #fun')
    expect(messages_to('#logs')).to eq(['[notice] carol has requested me join #fun'])
  end

  it 'ignores invites unless :join_on_invite is set' do
    Config.options = {}
    feed ':carol!carol@carol.host INVITE Zeta :#fun'
    expect(sent).not_to include('JOIN #fun')
  end
end
