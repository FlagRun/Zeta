# frozen_string_literal: true

RSpec.describe Plugins::Fnord do
  it 'replies with a generated headline' do
    say 'bob', '.fnord'
    expect(replies.size).to eq(1)
    expect(replies.first).to match(/\A\S.*\.\z/)
  end

  it 'generates tidy headlines for every template' do
    srand(1234)
    headlines = Array.new(300) { Plugins::Fnord::Fnord.headline }
    expect(headlines).to all(satisfy { |h| !h.include?('  ') && !h.start_with?(' ') && !h.include?(' .') })
    expect(headlines.map { |h| h[0] }).to all(satisfy { |c| c == c.upcase })
  end
end
