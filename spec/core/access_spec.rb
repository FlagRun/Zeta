# frozen_string_literal: true

module AclProbes
  LEVELS = %i[oper owner admin op operator halfop voice nobody].freeze

  LEVELS.each do |level|
    probe = Class.new do
      include Cinch::Plugin
      match "probe_#{level}", method: :probe
      define_method(:probe) { |m| m.reply "#{level} ok" }
    end
    const_set("Probe#{level.to_s.capitalize}", probe)
    probe.enable_acl(level)
  end

  SecureProbe = Class.new do
    include Cinch::Plugin
    match 'probe_secure', method: :probe
    def probe(m) = m.reply('secure ok')
  end
  SecureProbe.enable_acl(:op, true)

  ALL = LEVELS.map { |l| const_get("Probe#{l.to_s.capitalize}") } + [SecureProbe]
end

RSpec.describe 'Access control (enable_acl)' do
  before(:context) { AclProbes::ALL.each { |k| Bot.plugins.register_plugin(k) } }
  after(:context) do
    Bot.plugins.select { |p| AclProbes::ALL.include?(p.class) }.each { |p| Bot.plugins.unregister_plugin(p) }
  end

  def allowed?(nick, level, channel: '#test')
    before = messages_to(channel).count("#{level} ok")
    say nick, ".probe_#{level}", channel: channel
    messages_to(channel).count("#{level} ok") > before
  end

  # NAMES: ~olly &adam @oscar %hal +alice bob carol opal(oper)
  {
    nobody: { allowed: %w[bob alice], denied: [] },
    voice: { allowed: %w[alice], denied: %w[bob hal oscar] },
    halfop: { allowed: %w[hal], denied: %w[alice oscar] },
    op: { allowed: %w[oscar], denied: %w[hal adam bob] },
    operator: { allowed: %w[oscar], denied: %w[hal bob] },
    owner: { allowed: %w[olly], denied: %w[adam oscar bob] },
    admin: { allowed: %w[adam], denied: %w[oscar bob] },
    oper: { allowed: %w[opal], denied: %w[bob oscar adam] }
  }.each do |level, who|
    context "with level :#{level}" do
      who[:allowed].each do |nick|
        it("allows #{nick}") { expect(allowed?(nick, level)).to be(true) }
      end
      who[:denied].each do |nick|
        it("denies #{nick}") { expect(allowed?(nick, level)).to be(false) }
      end
    end
  end

  it 'lets IRC operators override channel levels' do
    expect(allowed?('opal', :admin)).to be(true)
  end

  it 'does not apply the oper override in #services' do
    expect(allowed?('opal', :admin, channel: '#services')).to be(false)
  end

  it 'disables the oper override when Config.oper_overide is false' do
    Config.oper_overide = false
    expect(allowed?('opal', :admin)).to be(false)
    expect(allowed?('opal', :oper)).to be(true)
  end

  it 'ignores every command in a blacklisted channel' do
    Blacklist.channels << '#test'
    expect(allowed?('bob', :nobody)).to be(false)
  end

  it 'ignores blacklisted users' do
    Blacklist.users << 'bob'
    expect(allowed?('bob', :nobody)).to be(false)
    expect(allowed?('carol', :nobody)).to be(true)
  end

  it 'checks privileges in Config.secure_channel when secure_chan is set' do
    expect(allowed?('oscar', :secure)).to be(false)

    IrcHarness.sync_channel!('#secure', '@Zeta @oscar bob')
    expect(allowed?('oscar', :secure)).to be(true)
    expect(allowed?('bob', :secure)).to be(false)
  end

  # The 'identify' and 'hostmask' modes are TODOs: check? returns nil and
  # Cinch only skips a handler when a pre-hook returns exactly false.
  it 'performs no level checks for the unimplemented secure modes' do
    Config.secure_mode = 'identify'
    expect(allowed?('bob', :admin)).to be(true)
  end
end
