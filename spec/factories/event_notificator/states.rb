# frozen_string_literal: true

FactoryBot.define do
  factory :event_notificator_state, class: Turtle::EventNotificator::State do
    initialize_with { new(:completed) }
  end
end
