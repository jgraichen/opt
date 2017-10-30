# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in opt.gemspec
gemspec

gem 'rake'

group :test do
  gem 'codeclimate-test-reporter', require: nil
  gem 'coveralls', require: nil
  gem 'rspec', '~> 3.0', require: nil
end

group :development do
  gem 'redcarpet', platform: :ruby
  gem 'yard'
end
