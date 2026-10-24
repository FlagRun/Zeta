# frozen_string_literal: true

RSpec.describe Plugins::Rainbow do
  def strip_formatting(text)
    text.gsub(/\x03\d{2}(,\d{2})?/, '').delete("\x02")
  end

  it 'colours every character' do
    say 'bob', '.rainbow hello'
    expect(replies.size).to eq(1)
    expect(replies.first.scan(/\x03\d{2}./)).to have_attributes(size: 5)
    expect(strip_formatting(replies.first)).to eq('hello')
  end

  it 'eyerapes text in bold alternating case' do
    say 'bob', '.eyerape hello world'
    expect(replies.first).to start_with("\x02")
    expect(strip_formatting(replies.first)).to eq('HeLlO WoRlD')
  end

  it 'adds String#irc_colorize' do
    expect('![b]bold![b]'.irc_colorize).to eq("\x02bold\x02")
  end
end
