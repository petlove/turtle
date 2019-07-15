FactoryBot.define do
  factory :event_notificator_event, class: Turtle::EventNotificator::Event do
    initialize_with { new(:completed) }
  end
end
