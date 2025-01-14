# frozen_string_literal: true

FactoryBot.define do
  factory :subscriber, class: AWS::SNS::Configurator::Subscriber do
    initialize_with { new({ name: 'customer', region: 'us-east-1' }, nil, nil, {}) }

    factory :subscriber_sqs do
      protocol { 'sqs' }
      endpoint { 'arn' }
      options { { raw: true } }
    end
  end
end
