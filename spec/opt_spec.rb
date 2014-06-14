require 'spec_helper'

describe Opt do
  let(:opt) { Opt.new }

  it 'should parse arguments (I)' do
    opt = Opt.new
    opt.option '--help, -h'

    result = opt.parse %w(-h)
    expect(result.help).to be true
  end

  it 'should detect double-dash' do
    opt = Opt.new
    opt.option '-v', name: :version
    opt.option 'rest', nargs: (0..Float::INFINITY)

    result = opt.parse %w(-v -- -h)
    expect(result.version?).to eq true
    expect(result.rest).to eq %w(-h)
  end

  it 'should parse arguments (II)' do
    opt = Opt.new
    opt.option '--help'
    opt.option '--version'

    result = opt.parse %w(--version)
    expect(result.version).to be true
    expect(result.help).to be false
  end

  it 'should parse arguments (III)' do
    pending

    opt = Opt.new
    opt.option :force, '-f, --force', default: false
    opt.option :quiet, '-q, --quiet', default: true

    result = opt.parse %w(--force)
    expect(result[:force]).to be true
    expect(result[:quiet]).to be true

    result = opt.parse %w(--no-force -q)
    expect(result[:force]).to be false
    expect(result[:quiet]).to be true

    result = opt.parse %w(-f --no-quiet)
    expect(result[:force]).to be true
    expect(result[:quiet]).to be false

    result = opt.parse %w(--no-quiet)
    expect(result[:force]).to be false
    expect(result[:quiet]).to be false
  end

  it 'should parse subcommands (I)' do
    pending

    opt = Opt.new
    opt.option :version, '-v, --version'

    opt.command :add, 'Add some things' do |cmd|
      cmd.option :version, '-v, --version'
    end

    result = opt.parse %w(-v add -v)

    expect(result[:version]).to eq true
    expect(result.command.name).to eq :add
    expect(result.command[:verbose]).to eq true
  end
end
