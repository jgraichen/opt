require 'rspec'

if ENV['CI'] || ENV['COVERAGE']
  require 'coveralls'
  Coveralls.wear! do
    add_filter 'spec'
  end
end

require 'opt'

Dir[File.expand_path('spec/support/**/*.rb')].each {|f| require f }

RSpec.configure do |config|
  config.order = 'random'
end
