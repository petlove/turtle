# frozen_string_literal: true

FactoryBot.define do
  factory :event_notificator_action, class: Turtle::EventNotificator::Action do
    initialize_with { new(:updated) }
  end
end
