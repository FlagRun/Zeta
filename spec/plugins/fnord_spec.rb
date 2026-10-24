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

  it 'shows its help' do
    say 'bob', '.help fnord'
    expect(notices_to('bob')).to eq(["Help for \x02fnord\x0F:", 'fnord: ?fnord - Creates a fnord'])
  end

  # Every word list lookup picks the first entry; rand(14) picks the template and
  # the optional-word dice (rand(2) / rand(5)) all roll `roll` (0 = include, 1 = omit).
  # NB: PRONOUNS has 5 entries, so a roll of 1 also picks PRONOUNS[1] ("my").
  def fnord_with(template, roll)
    allow(Plugins::Fnord::Fnord).to receive(:rand) do |n|
      case n
      when 14 then template
      when 2, 5 then roll
      else 0
      end
    end
    say 'bob', '.fnord'
    replies
  end

  {
    0 => ['The 23rd 911 file in (not available at your clearance) is 23rd.',
          'The 911 file is 23rd.'],
    1 => ['007 amuses the 23rd 911 file and the 23rd 911 file.'] * 2,
    2 => ['The 911 file from (not available at your clearance) will go to (not available at your clearance).'] * 2,
    3 => ['007 must take the 23rd 911 file from (not available at your clearance).'] * 2,
    4 => ['(not available at your clearance) is 23rd and the 911 file is 23rd.'] * 2,
    5 => ['007 assumes responsibility for (not available at your clearance) for the 23rd 911 file.'] * 2,
    6 => ['The 23rd 911 file amuses the 23rd 911 file in (not available at your clearance).',
          'The 911 file amuses the 23rd 911 file.'],
    7 => ['007 assumes responsibility for (not available at your clearance) and amuses the 911 file.'] * 2,
    8 => ['007 takes his 23rd 911 file and assumes responsibility for (not available at your clearance).',
          '007 takes my 911 file and assumes responsibility for (not available at your clearance).'],
    9 => ['007 amuses the 23rd 911 file.', '007 amuses the 911 file.'],
    10 => ['007 amuses 007 and his 23rd 911 file.', '007 amuses 007 and my 911 file.'],
    11 => ['007 is the 23rd 911 file; 007 assumes responsibility for (not available at your clearance).',
           '007 is the 911 file; 007 assumes responsibility for (not available at your clearance).'],
    12 => ['You must meet 007 at (not available at your clearance) and get the 23rd 911 file.',
           'You must meet 007 at (not available at your clearance) and get the 911 file.'],
    13 => ['A 911 file from (not available at your clearance) amuses the 23rd 23rd 911 file.',
           'A 911 file from (not available at your clearance) amuses the 911 file.']
  }.each do |template, (with_optional, without_optional)|
    it "renders template #{template} with its optional words" do
      expect(fnord_with(template, 0)).to eq([with_optional])
    end

    it "renders template #{template} without its optional words" do
      expect(fnord_with(template, 1)).to eq([without_optional])
    end
  end
end
