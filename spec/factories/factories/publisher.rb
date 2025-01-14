# frozen_string_literal: true

FactoryBot.define do
  factory :publisher, class: AWS::SNS::Configurator::Publisher do
    initialize_with { new({ name: 'customer', region: 'us-east-1' }, name: 'linqueta', blog: 'linqueta.com') }
  end
end
