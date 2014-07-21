require 'spec_helper'

describe Opt do
  let(:opt) { Opt.new }

  it 'should parse options (I)' do
    opt.option '--help, -h', value: :yes

    result = opt.parse %w(-h)
    expect(result.help).to eq :yes

    result = opt.parse %w()
    expect(result.help).to eq nil
  end

  it 'should detect double-dash' do
    opt.option '-v', name: :version
    opt.option 'rest', nargs: 1..Opt::Inf

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

  it 'should parse options with argument & block' do
    opt.option '--level, -l', nargs: 2..3 do |levels|
      levels.map(&method(:Integer))
    end

    result = opt.parse %w(--level 5 6)
    expect(result.level).to eq [5, 6]
  end

  it 'should parse flags' do
    pending

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
    opt.option '--force, -f'

    opt.command :add, 'Add some things' do |cmd|
      cmd.option '--verbose'
    end

    result = opt.parse %w(-f add --verbose)

    expect(result.force?).to eq true
    expect(result.verbose?).to eq true
    expect(result.command.first).to be_a Opt::Command
    expect(result.command.map(&:name)).to eq %w(add)

    result = opt.parse %w(add -f --verbose)

    expect(result.force?).to eq true
    expect(result.verbose?).to eq true
    expect(result.command.map(&:name)).to eq %w(add)
  end

  it 'should parse subcommands (II)' do
    opt.option '-f'

    opt.command :add, 'Add some things' do |cmd|
      cmd.option '-a'
      cmd.option '-j', nargs: 1
    end

    result = opt.parse %w(add -af)

    expect(result.a?).to eq true
    expect(result.f?).to eq true
    expect(result.command.map(&:name)).to eq %w(add)

    result = opt.parse %w(add -ajf)

    expect(result.a?).to eq true
    expect(result.f?).to eq nil
    expect(result.j).to eq 'f'
    expect(result.command.map(&:name)).to eq %w(add)
  end
end
