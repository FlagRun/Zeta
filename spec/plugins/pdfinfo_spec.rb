# frozen_string_literal: true

RSpec.describe Plugins::PDFinfo do
  let(:url) { 'https://files.example/paper.pdf' }

  def build_pdf(info)
    objects = ['<< /Type /Catalog /Pages 2 0 R >>',
               '<< /Type /Pages /Kids [3 0 R] /Count 1 >>',
               '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] >>',
               info]
    pdf = +"%PDF-1.4\n"
    offsets = objects.each_with_index.map do |obj, i|
      pdf.bytesize.tap { pdf << "#{i + 1} 0 obj\n#{obj}\nendobj\n" }
    end
    xref = pdf.bytesize
    pdf << "xref\n0 #{objects.size + 1}\n0000000000 65535 f \n"
    offsets.each { |o| pdf << format("%010d 00000 n \n", o) }
    pdf << "trailer\n<< /Size #{objects.size + 1} /Root 1 0 R /Info 4 0 R >>\nstartxref\n#{xref}\n%%EOF\n"
  end

  def serve(pdf, length: pdf.bytesize)
    stub_request(:head, url).to_return(headers: { 'Content-Length' => length.to_s })
    stub_request(:get, url).to_return(body: pdf)
  end

  it 'shows the title of linked PDFs' do
    serve(build_pdf('<< /Title (Zeta Manual) /Creator (rspec) >>'), length: 2048)
    say 'bob', "read this #{url} please"
    expect(replies).to eq(['PDF (2kb) → Zeta Manual'])
  end

  it 'falls back to metadata without a title' do
    serve(build_pdf('<< /Producer (Printer) >>'))
    say 'bob', url
    expect(replies).to eq(['PDF (0kb) → Title: None <> Creator: Anon <> Producer: Printer <> Creation: now'])
  end

  it 'refuses files over the size limit' do
    stub_request(:head, url).to_return(headers: { 'Content-Length' => '5000000' })
    say 'bob', url
    expect(replies).to eq(['PDF → Unable to parse. file too big 4882kb'])
    expect(a_request(:get, url)).not_to have_been_made
  end

  it 'ignores non-PDF links' do
    say 'bob', 'https://files.example/page.html'
    expect(replies).to be_empty
  end

  it 'logs fetch errors without replying', :allow_errors do
    stub_request(:head, url).to_return(status: 404)
    stub_request(:get, url).to_return(status: 404)
    say 'bob', url
    expect(replies).to be_empty
    expect(IrcHarness.error_log.lines.map { _1.chomp.split(' !! ', 2).last })
      .to eq(['[Plugins::PDFinfo] OpenURI::HTTPError: 404 '])
  end

  it 'parses files right at the size limit and refuses one byte more' do
    serve(build_pdf('<< /Title (Edge) >>'), length: 4_000_000)
    say 'bob', url
    stub_request(:head, url).to_return(headers: { 'Content-Length' => '4000001' })
    say 'bob', url
    expect(replies).to eq(['PDF (3906kb) → Edge', 'PDF → Unable to parse. file too big 3906kb'])
  end

  it 'also inspects links matching extra configured patterns' do
    options = Bot.config.plugins.options
    options[described_class] = { blacklist: [%r{/download/\d+$}] }
    download = 'https://files.example/download/42'
    stub_request(:head, download).to_return(headers: { 'Content-Length' => '1024' })
    stub_request(:get, download).to_return(body: build_pdf('<< /Title (Configured) >>'))
    say 'bob', download
    expect(replies).to eq(['PDF (1kb) → Configured'])
  ensure
    options.delete(described_class)
  end

  it 'documents itself in the help listing' do
    say 'bob', '.help pdf information'
    expect(notices_to('bob')).to eq(["Help for \x02PDF Information\x0F:",
                                     'This plugin will check a url for a pdf link and fetch metadata from it'])
  end
end
