# frozen_string_literal: true

require 'bundler/setup'
require 'aws/sns/configurator'

namespace :aws do
  namespace :sns do
    desc 'Create topics by config (./config/aws-sns-configurator.yml)'
    task :create do |_t, _args|
      AWS::SNS::Configurator.create!
    end
  end
end
