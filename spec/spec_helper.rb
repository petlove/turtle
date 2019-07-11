require 'bundler/setup'
require 'config/simple_cov_config'
SimpleCovConfig.configure

require 'turtle'

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
