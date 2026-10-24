# frozen_string_literal: true

RSpec.describe Admin::Fifo do
  let(:path) { File.join(Dir.home, '.zeta', 'zeta.io') }

  def wait_until(timeout = 5)
    deadline = Time.now + timeout
    sleep 0.05 until yield || Time.now > deadline
    yield
  end

  it 'relays lines written to the named pipe to the IRC server and cleans up on disconnect' do
    File.write(path, 'stale') # left over from a crash
    reader = Thread.new { plugin(described_class).open_fifo(nil) }

    expect(wait_until { File.pipe?(path) }).to be(true)
    expect(File.stat(path).mode & 0o777).to eq(0o660)

    File.open(path, 'w') { |f| f.puts '  PRIVMSG #test :hello from the pipe  ' }
    expect(wait_until { sent.include?('PRIVMSG #test :hello from the pipe') }).to be(true)

    plugin(described_class).close_fifo(nil)
    expect(File.exist?(path)).to be(false)
  ensure
    reader&.kill&.join
    FileUtils.rm_f(path)
  end
end
