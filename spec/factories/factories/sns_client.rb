# frozen_string_literal: true

FactoryBot.define do
  factory :sns_client, class: AWS::SNS::Configurator::Client do
    initialize_with { new('us-east-1') }
  end
end
