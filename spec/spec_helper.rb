require 'rspec'

if ENV['CI'] || ENV['COVERAGE']
  require 'coveralls'
  Coveralls.wear! do
    add_filter 'spec'
  end
end

Bundler.require :default, :test

# Load stic
require 'opt'

# Load spec support files
Dir[File.expand_path('spec/support/**/*.rb')].each {|f| require f }

RSpec.configure do |config|
  # Random order
  config.order = 'random'

  config.around(:each) do |example|
    Path::Backend.mock(&example)
  end
end
