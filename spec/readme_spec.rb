require 'spec_helper'

describe Opt do
  let(:opt) { Opt.new }

  it 'should pass README examples' do
    content = File.read(File.expand_path('../../README.md', __FILE__))

    while content =~ /^```ruby\n(.*?)^```\n(.*?)\z/m
      example = $1
      content = $2

      example.gsub!(/^\s*(.*?)\s*#=>\s*(.*?)\s*$/, 'expect( \1 ).to eq( \2 )')

      instance_eval example, __FILE__, __LINE__
    end
  end
end
