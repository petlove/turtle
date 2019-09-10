# frozen_string_literal: true

source 'https://rubygems.org'

gem 'aws-sns-configurator', github: 'petlove/aws-sns-configurator'
gem 'aws-sqs-configurator', github: 'petlove/aws-sqs-configurator'
gem 'honeybadger', '~> 4.0'

group :development, :test do
  gem 'factory_bot'
  gem 'pry'
  gem 'rubocop'
  gem 'rubocop-performance'
end

group :test do
  gem 'rspec'
  gem 'simplecov', require: false
  gem 'simplecov-console'
  gem 'simplecov-summary'
end

gemspec
