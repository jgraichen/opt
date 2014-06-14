require 'rspec'

if ENV['CI'] || ENV['COVERAGE']
  require 'coveralls'
  Coveralls.wear! do
    add_filter 'spec'
  end
end

# Load stic
require 'opt'

# Load spec support files
Dir[File.expand_path('spec/support/**/*.rb')].each {|f| require f }

RSpec.configure do |config|
  # Random order
  config.order = 'random'
end
