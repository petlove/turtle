# frozen_string_literal: true

FactoryBot.define do
  factory :sqs_client, class: AWS::SQS::Configurator::Client do
    initialize_with { new('us-east-1') }
  end
end
