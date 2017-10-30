# frozen_string_literal: true
# require 'spec_helper'

# describe Opt::Flag do
#   shared_examples 'defined flag' do
#     it 'should match short code' do
#       ret = option.parse %w(-v)
#       expect(ret).to eq [true]
#     end

#     it 'should match long code' do
#       ret = option.parse %w(--verbose)
#       expect(ret).to eq [true]
#     end

#     it 'should match negated long code' do
#       ret = option.parse %w(--no-verbose)
#       expect(ret).to eq [false]
#     end

#     it 'should not match something else' do
#       ret = option.parse %w(--fuu)
#       expect(ret).to be_false
#     end
#   end

#   context 'as simple flag' do
#     let(:option) { Opt::Flag.new :name, '-v, --verbose' }

#     it_should_behave_like 'defined flag'
#   end

#   context 'with undashed flag' do
#     let(:option) { Opt::Flag.new :name, 'v, verbose' }

#     it_should_behave_like 'defined flag'
#   end

#   context 'with multiple flags' do
#     let(:option) { Opt::Flag.new :name, 'v, verbose, a, ausführlich' }

#     it_should_behave_like 'defined flag'

#     it 'should match second short code' do
#       ret = option.parse %w(-a)
#       expect(ret).to eq [true]
#     end

#     it 'should match second long code' do
#       ret = option.parse %w(--ausführlich)
#       expect(ret).to eq [true]
#     end

#     it 'should match second negated long code' do
#       ret = option.parse %w(--no-ausführlich)
#       expect(ret).to eq [false]
#     end
#   end

#   context 'with single-dash long flag' do
#     let(:option) { Opt::Flag.new :name, '-with-recommended' }

#     it 'should match code' do
#       ret = option.parse %w(-with-recommended)
#       expect(ret).to eq [true]
#     end

#     it 'should negated code' do
#       ret = option.parse %w(-without-recommended)
#       expect(ret).to eq [false]
#     end
#   end

#   context 'with already negated flag' do
#     let(:option) { Opt::Flag.new :name, '--without-recommended' }

#     it 'should match code' do
#       ret = option.parse %w(--with-recommended)
#       expect(ret).to eq [false]
#     end

#     it 'should negated code' do
#       ret = option.parse %w(--without-recommended)
#       expect(ret).to eq [true]
#     end

#     context 'with default: false' do
#       let(:option) { Opt::Flag.new :name, '--without-recommended', default: false }

#       it 'should match code' do
#         ret = option.parse %w(--with-recommended)
#         expect(ret).to eq [true]
#       end

#       it 'should negated code' do
#         ret = option.parse %w(--without-recommended)
#         expect(ret).to eq [false]
#       end
#     end
#   end
# end
