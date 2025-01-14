# frozen_string_literal: true

FactoryBot.define do
  factory :topic, class: AWS::SNS::Configurator::Topic do
    initialize_with { new(name: 'update_price', region: 'us-east-1') }

    name { 'update_price' }
    region { 'us-east-1' }
    prefix { 'prices' }
    suffix { 'warning' }
    environment { 'production' }
    metadata { { type: 'strict' } }
  end
end
