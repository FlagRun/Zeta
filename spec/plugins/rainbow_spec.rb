# frozen_string_literal: true

RSpec.describe Plugins::Rainbow do
  def strip_formatting(text)
    text.gsub(/\x03\d{2}(,\d{2})?/, '').delete("\x02")
  end

  # pick: :min or :max of the range passed to Random#rand
  def start_colour_at(pick)
    rng = instance_double(Random)
    allow(rng).to receive(:rand) { |range| range.public_send(pick) }
    allow(Random).to receive(:new).and_return(rng)
  end

  it 'colours every character' do
    say 'bob', '.rainbow hello'
    expect(replies.size).to eq(1)
    expect(replies.first.scan(/\x03\d{2}./)).to have_attributes(size: 5)
    expect(strip_formatting(replies.first)).to eq('hello')
  end

  it 'cycles through the rainbow from the first colour' do
    start_colour_at(:min)
    say 'bob', '.rainbow hello'
    expect(replies).to eq(["\x0304h\x0307e\x0308l\x0309l\x0310o"])
  end

  it 'wraps around to the first colour after the last one' do
    start_colour_at(:max)
    say 'bob', '.rainbow abcdefgh'
    expect(replies).to eq(["\x0313a\x0304b\x0307c\x0308d\x0309e\x0310f\x0306g\x0313h"])
  end

  it 'strips existing colour codes before rainbowifying' do
    start_colour_at(:min)
    say 'bob', ".rainbow \x0312,04hi"
    expect(replies).to eq(["\x0304h\x0307i"])
  end

  it 'eyerapes text in bold alternating case' do
    say 'bob', '.eyerape hello world'
    expect(replies.first).to start_with("\x02")
    expect(strip_formatting(replies.first)).to eq('HeLlO WoRlD')
  end

  it 'gives each eyeraped word the next foreground/background colour pair' do
    start_colour_at(:min)
    say 'bob', '.eyerape ab cd ef gh ij kl mn op'
    expect(replies).to eq(["\x02\x0307,10Ab \x0308,06Cd \x0309,13Ef \x0310,04Gh " \
                           "\x0306,07Ij \x0313,08Kl \x0304,09Mn \x0307,10Op"])
  end

  it 'wraps eyerape colours around after the last one' do
    start_colour_at(:max)
    say 'bob', '.eyerape hello world'
    expect(replies).to eq(["\x02\x0304,09HeLlO \x0307,10WoRlD"])
  end

  it 'adds String#irc_colorize' do
    expect('![b]bold![b]'.irc_colorize).to eq("\x02bold\x02")
  end

  it 'maps every irc_colorize code letter to its control character' do
    expect('![boruic]x![]'.irc_colorize).to eq("\x02\x0F\x12\x1F\x1D\x03x")
  end
end
