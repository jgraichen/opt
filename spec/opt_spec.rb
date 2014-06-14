require 'spec_helper'

describe Opt do
  let(:opt) { Opt.new }

  it 'should parse options (I)' do
    opt.option '--help, -h', value: :yes

    result = opt.parse %w(-h)
    expect(result.help).to eq :yes
  end

  it 'should detect double-dash' do
    opt.option '-v', name: :version
    opt.option 'rest', nargs: '+'

    result = opt.parse %w(-v -- -h)
    expect(result.version?).to be true
    expect(result.rest).to eq %w(-h)
  end

  it 'should parse options (II)' do
    opt.option '--help', default: :no
    opt.option '--version'

    result = opt.parse %w(--version)
    expect(result.version).to eql true
    expect(result.help).to eql :no
  end

  it 'should parse options with argument' do
    opt.option '--level, -l', nargs: 1

    result = opt.parse %w(--level 5)
    expect(result.level).to eq '5'

    result = opt.parse %w(--level=5)
    expect(result.level).to eq '5'

    result = opt.parse %w(-l 5)
    expect(result.level).to eq '5'

    result = opt.parse %w(-l5)
    expect(result.level).to eq '5'
  end

  it 'should parse options with arguments' do
    opt.option '--level, -l', nargs: 2..3

    result = opt.parse %w(--level 5 6)
    expect(result.level).to eq %w(5 6)

    result = opt.parse %w(-l 5 6)
    expect(result.level).to eq %w(5 6)
  end

  it 'should parse flags' do
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
