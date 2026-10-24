# frozen_string_literal: true

RSpec.describe 'load_locale' do
  locale_dir = File.expand_path('../../lib/Zeta/locale/en', __dir__)

  # 8ball.yml ships empty (the plugin keeps its answers inline)
  Dir[File.join(locale_dir, '*.yml')].reject { |f| File.zero?(f) }.each do |path|
    name = File.basename(path, '.yml')

    it "parses the bundled #{name} locale" do
      expect(load_locale(name)).not_to be_nil
    end
  end

  it 'returns the bundled data' do
    expect(load_locale('dbz')['over9k']).to include("It's over 9000!!!")
    expect(load_locale('macros')['dnf']).to eq('Duke Nukem Forever came out. Your argument is invalid.')
  end

  it 'prefers a user override in ~/.zeta/locale/<locale>' do
    dir = File.join(Dir.home, '.zeta', 'locale', 'en')
    FileUtils.mkdir_p(dir)
    File.write(File.join(dir, 'dbz.yml'), { 'over9k' => ['custom'] }.to_yaml)

    expect(load_locale('dbz')).to eq('over9k' => ['custom'])
  ensure
    FileUtils.rm_rf(dir)
  end

  it 'defaults to english when no locale is configured' do
    Config.locale = nil
    expect(load_locale('dbz')).to have_key('over9k')
    expect(Config.locale).to eq('en')
  end
end
