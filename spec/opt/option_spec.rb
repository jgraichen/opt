require 'spec_helper'

RSpec::Matchers.define :parse do |*expected|
  match do |option|
    result = {}
    argv   = expected.dup
    option.parse!(argv, result)

    expect(result).to include results  if results.any?
    expect(argv).to eq expected[1..-1] if shift?
  end

  chain :emit do |hash|
    results.merge! hash
  end

  chain :shift_argv do
    @shift = true
  end

  def shift?
    @shift.nil? ? (@shift = false) : @shift
  end

  def results
    @results ||= {}
  end
end

def t(type, value)
  Opt::Command::Token.new(type, value)
end

describe Opt::Option do
  let(:option) { described_class.new(defin, {name: :test}.merge(opts)) }
  let(:defin) { '' }
  let(:opts)  { {} }
  subject { option }

  describe '.parse_nargs' do
    it 'should parse single fixnum' do
      expect(described_class.parse_nargs(5)).to eq 5..5
    end

    it 'should parse range' do
      expect(described_class.parse_nargs(2..6)).to eq 2..6
    end

    it 'should parse fixnum string' do
      expect(described_class.parse_nargs('12')).to eq 12..12
    end

    it 'should reject invalid string' do
      expect do
        described_class.parse_nargs('a12')
      end.to raise_error(/invalid value for Integer/)
    end

    it 'should flip negative range' do
      expect(described_class.parse_nargs(6..2)).to eq 2..6
    end

    it 'should reject negative range' do
      expect do
        described_class.parse_nargs(-2..2)
      end.to raise_error(/Argument number must not be less than zero/)
    end
  end

  describe '#initialize' do
    it 'should derive name from switches (I)' do
      expect(described_class.new('-h').name).to eq 'h'
    end

    it 'should derive name from switches (II)' do
      expect(described_class.new('--help').name).to eq 'help'
    end

    it 'should use name from opts' do
      expect(described_class.new('--help', name: :test).name).to eq 'test'
    end

    it 'should parse switches' do
      option = described_class.new('-h, --help')
      expect(option.switches.size).to eq 2
      expect(option.switches.each.map(&:name)).to match_array %w(h help)
    end

    it 'should parse free-text arg' do
      option = described_class.new('file', nargs: 0..Float::INFINITY)
      expect(option.switches.size).to eq 0
      expect(option).to be_text
      expect(option.name).to eq 'file'
    end
  end

  describe '#parse!' do
    context 'with shirt code' do
      let(:defin) { '-h, -2, -め' }

      it 'should match short token' do
        option.parse! argv = [t(:short, 'h')], result = {}

        expect(argv).to be_empty
        expect(result).to eq 'test' => true
      end

      it 'should match grouped short token' do
        option.parse! argv = [t(:short, '2b4')], result = {}

        expect(argv.size).to eq 1
        expect(argv.first.value).to eq 'b4'
        expect(result).to eq 'test' => true
      end

      it 'should match short unicode token' do
        option.parse! argv = [t(:short, 'め')], result = {}

        expect(argv).to be_empty
        expect(result).to eq 'test' => true
      end

      it 'should not match long token' do
        option.parse! argv = [t(:long, 'め')], result = {}

        expect(argv.size).to eq 1
        expect(result).to be_empty
      end

      it 'should not match different short token' do
        option.parse! argv = [t(:short, '1')], result = {}

        expect(argv.size).to eq 1
        expect(result).to be_empty
      end
    end

    context 'with long code' do
      let(:defin) { '--help, --2, --めこそ' }

      it 'should match long argv (I)' do
        option.parse! argv = [t(:long, 'help')], result = {}

        expect(argv).to be_empty
        expect(result).to eq 'test' => true
      end

      it 'should match long argv (II)' do
        option.parse! argv = [t(:long, '2')], result = {}

        expect(argv).to be_empty
        expect(result).to eq 'test' => true
      end

      it 'should match long argv (III)' do
        option.parse! argv = [t(:long, 'めこそ')], result = {}

        expect(argv).to be_empty
        expect(result).to eq 'test' => true
      end
    end

    context 'with free-text' do
      let(:defin) { 'file' }
      let(:opts) { {nargs: 1} }

      it 'should match text' do
        option.parse! argv = [t(:text, 'help')], result = {}

        expect(argv).to be_empty
        expect(result).to eq 'test' => 'help'
      end

      context 'with lower bound' do
        let(:opts) { {nargs: 2..Float::INFINITY} }

        it 'should reject to less arguments' do
          expect do
            option.parse! [t(:text, 'a')], {}
          end.to raise_error(/wrong number of arguments/)
        end

        it 'should accept enough arguments' do
          option.parse! argv = [t(:text, 'a'), t(:text, 'b')], result = {}

          expect(argv).to be_empty
          expect(result).to eq 'test' => %w(a b)
        end
      end

      context 'with upper bound' do
        let(:opts) { {nargs: 0..2} }

        it 'should eat arguments up to upper bound' do
          option.parse! argv   = [t(:text, 'a'), t(:text, 'b'), t(:text, 'c')],
                        result = {}

          expect(argv).to eq [t(:text, 'c')]
          expect(result).to eq 'test' => %w(a b)
        end

        it 'should eat less arguments if there are less tokens' do
          option.parse! argv = [t(:text, 'a'), t(:short, 'b'), t(:text, 'c')],
                        result = {}

          expect(argv).to eq [t(:short, 'b'), t(:text, 'c')]
          expect(result).to eq 'test' => %w(a)
        end
      end
    end
  end
end
