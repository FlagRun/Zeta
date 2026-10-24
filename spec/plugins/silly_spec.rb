# frozen_string_literal: true

RSpec.describe Plugins::Silly do
  describe 'countdowns' do
    it 'counts down to Christmas' do
      travel_to(Time.utc(2026, 12, 24)) { say 'bob', '.xmas' }
      expect(replies).to eq(["bob: There's 1 day until Christmas!"])
    end

    it 'celebrates Christmas' do
      travel_to(Time.utc(2026, 12, 25, 12)) { say 'bob', '.xmas' }
      expect(replies).to eq(['bob: Merry Christmas!'])
    end

    it 'rolls over to next Christmas' do
      travel_to(Time.utc(2026, 12, 26, 12)) { say 'bob', '.xmas' }
      # ChronicDuration counts 30 day months
      expect(replies).to eq(["bob: There's 12 months 3 days 12 hours until Christmas!"])
    end

    it 'celebrates Halloween' do
      travel_to(Time.utc(2026, 10, 31, 12)) { say 'bob', '.halloween' }
      expect(replies).to eq(['bob: THIS IS HALLOWEEN!'])
    end

    it 'answers to .halloweve too' do
      travel_to(Time.utc(2026, 10, 31, 12)) { say 'bob', '.halloweve' }
      expect(replies).to eq(['bob: THIS IS HALLOWEEN!'])
    end

    it 'rolls over to next Halloween once it has passed' do
      travel_to(Time.utc(2026, 11, 1, 12)) { say 'bob', '.halloween' }
      expect(replies).to eq(["bob: There's 12 months 3 days 12 hours until Hallow's Eve!"])
    end

    it 'counts down to Halloween in a timezone' do
      travel_to(Time.utc(2026, 10, 30, 12)) { say 'bob', '.halloween -5' }
      expect(replies).to eq(["bob: There's 17 hours until Hallow's Eve!"])
    end

    it 'counts down to the new year' do
      travel_to(Time.utc(2026, 12, 31, 12)) { say 'bob', '.newyear' }
      expect(replies).to eq(["bob: There's 12 hours until 2027!"])
    end
  end

  describe '.tz' do
    it 'shows the time in a UTC offset' do
      travel_to(Time.utc(2026, 1, 1)) { say 'bob', '.tz +5:30' }
      expect(replies).to eq(['bob: 2026-01-01 05:30:00 +0530'])
    end

    it 'defaults to UTC' do
      travel_to(Time.utc(2026, 1, 1)) { say 'bob', '.tz' }
      expect(replies).to eq(['bob: 2026-01-01 00:00:00 UTC'])
    end

    %w[123 5:123 +5:300].each do |offset|
      it "rejects the over-long offset #{offset}" do
        say 'bob', ".tz #{offset}"
        expect(replies).to eq(['bob: A valid timezone was not supplied.'])
      end
    end

    %w[tz xmas halloween newyear].each do |cmd|
      it "reports invalid timezones for .#{cmd}" do
        say 'bob', ".#{cmd} mars"
        expect(replies).to eq(['bob: A valid timezone was not supplied.'])
      end
    end
  end

  describe 'Silly#tzparser' do
    subject(:silly) { plugin(described_class) }

    { '5' => '+05:00', '-3' => '-03:00', '+10:30' => '+10:30', '-0:5' => '-00:05' }.each do |input, output|
      it("normalises #{input.inspect}") { expect(silly.tzparser(input)).to eq(output) }
    end

    it 'rejects garbage' do
      expect { silly.tzparser('abc') }.to raise_error(ArgumentError)
    end
  end

  {
    Date.new(2012, 12, 20) => '13.0.0.0.0',
    Date.new(2012, 12, 21) => '13.0.0.0.1',
    Date.new(2026, 1, 1) => '13.0.13.4.0'
  }.each do |date, long_count|
    it "prints the Mayan long count for #{date}" do
      travel_to(date.to_time + 12 * 3600) { say 'bob', '.mayan' }
      expect(replies).to eq([long_count])
    end
  end

  it 'heavymetalizes text' do
    say 'bob', '.heavymetalize Iron Maiden'
    expect(replies).to eq(['Ïrön Mäïdën'])
  end

  # The comebacks are picked at random; given enough tries every one shows up.
  it 'responds to bot insults' do
    say 'bob', 'what a stupid bot'
    expect(replies.size).to eq(1)

    80.times { say 'bob', 'you dumb bot' }
    expect(replies.uniq).to match_array(['Stupid human!', 'Dumb human!', 'Stupid meatbag.',
                                         'Silly human, your insults cannot harm me!', 'get rekt', 'u fkn w0t m8'])
  end

  it 'responds to feature requests' do
    say 'bob', 'I have a feature request'
    expect(replies.size).to eq(1)

    80.times { say 'bob', 'feature request: more cowbell' }
    expect(replies.uniq).to match_array(['user error.', 'working as intended', 'Status: WONTFIX',
                                         'PEBKAC issue', 'ID:10T Error'])
  end

  describe 'poking' do
    before { plugin(described_class).pokers.clear }

    it 'escalates and finally kicks' do
      4.times { act 'bob', 'pokes Zeta' }
      expect(replies).to eq(['Do NOT poke the bot!'] * 3 + ['I said, do NOT poke the bot!'])

      act 'bob', 'pokes Zeta'
      expect(sent.grep(/\AKICK #test bob :/).size).to eq(1)
      expect(plugin(described_class).pokers).to be_empty
    end

    it 'ignores pokes aimed at others' do
      act 'bob', 'pokes carol'
      expect(replies).to be_empty
    end
  end
end
