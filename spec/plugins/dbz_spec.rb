# frozen_string_literal: true

RSpec.describe Plugins::DBZ do
  let(:quotes) { load_locale('dbz')['over9k'] }

  ['Over 9000', "it's Over Nine Thousand!", '9000', 'overninethousand'].each do |text|
    it "quotes DBZ for #{text.inspect}" do
      say 'bob', text
      expect(replies.size).to eq(1)
      expect(quotes).to include(replies.first)
    end
  end

  it 'stays quiet otherwise' do
    say 'bob', 'over 8999'
    expect(replies).to be_empty
  end

  it 'shows its help under its plugin name' do
    say 'bob', '.help dragonball z!'
    expect(notices_to('bob')).to eq(["Help for \x02DragonBall Z!\x0F:", "It's Over Nine Thousand!"])
  end
end
