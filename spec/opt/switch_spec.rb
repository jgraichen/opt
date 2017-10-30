
# frozen_string_literal: true

require 'spec_helper'

describe Opt::Switch do
  describe '.new' do
    subject { described_class.new arg }

    context 'with Switch object' do
      let(:arg) { described_class.new '-x' }

      it 'should return original switch object' do
        is_expected.to eql arg
      end
    end
  end

  describe '#initialize' do
    subject { described_class.new arg }

    context 'with short code string' do
      let(:arg) { '-h' }

      it 'should parse to short code' do
        expect(subject).to be_short
        expect(subject.name).to eq 'h'
      end
    end

    context 'with long code string' do
      let(:arg) { '--help' }

      it 'should parse to long code' do
        expect(subject).to be_long
        expect(subject.name).to eq 'help'
      end
    end

    context 'with unicode parameter string' do
      let(:arg) { '--めこそ' }

      it 'should parse to long code' do
        expect(subject).to be_long
        expect(subject.name).to eq 'めこそ'
      end
    end
  end

  describe '.parse' do
    subject { described_class.parse arg }

    context 'with string' do
      let(:arg) { '-h, --help, -h' }

      it 'should parse to Set' do
        expect(subject).to be_a Set
        expect(subject.size).to eq 2
        expect(subject.map(&:name)).to match_array %w[h help]
      end
    end
  end
end
