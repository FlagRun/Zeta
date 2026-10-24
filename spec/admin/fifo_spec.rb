# frozen_string_literal: true

RSpec.describe Admin::Fifo do
  let(:path) { File.join(Dir.home, '.zeta', 'zeta.io') }
  let(:fifo) { plugin(described_class) }

  def wait_until(timeout = 5)
    deadline = Time.now + timeout
    sleep 0.05 until yield || Time.now > deadline
    yield
  end

  def handler_for(event) = fifo.handlers.find { |h| h.event == event }

  it 'relays lines written to the named pipe to the IRC server and cleans up on disconnect' do
    File.write(path, 'stale') # left over from a crash
    reader = Thread.new { fifo.open_fifo(nil) }

    expect(wait_until { File.pipe?(path) }).to be(true)
    expect(File.stat(path).mode & 0o777).to eq(0o660)

    File.open(path, 'w') { |f| f.puts '  PRIVMSG #test :hello from the pipe  ' }
    expect(wait_until { sent.include?('PRIVMSG #test :hello from the pipe') }).to be(true)

    fifo.close_fifo(nil)
    expect(File.exist?(path)).to be(false)
  ensure
    reader&.kill&.join
    FileUtils.rm_f(path)
  end

  # The :connect handler never returns, so its handler thread is killed afterwards.
  it 'opens the pipe when the bot connects and removes it when it disconnects' do
    connect = handler_for(:connect)
    connect.call(nil, [], [])
    expect(wait_until { File.pipe?(path) }).to be(true)

    File.open(path, 'w') { |f| f.puts 'PRIVMSG #test :connected' }
    expect(wait_until { sent.include?('PRIVMSG #test :connected') }).to be(true)

    handler_for(:disconnect).call(nil, [], []).join
    expect(File.exist?(path)).to be(false)
  ensure
    connect&.thread_group&.list&.each { |t| t.kill.join }
    FileUtils.rm_f(path)
  end
end
