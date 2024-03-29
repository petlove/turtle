# frozen_string_literal: true

module Turtle
  module EventNotificator
    class Notification
      TOPIC_PREFIX_ENV = 'APP_NAME'
      TOPIC_ENVIRONMENT_ENV = 'APP_ENV'
      TOPIC_EVENT_PREFIX = 'event'

      attr_accessor :event

      def initialize(event)
        @event = event
      end

      def publish!(payload, options)
        Logger.info("[Event Notification] Model: #{options[:model]} Event: #{@event}")
        Turtle.publish!(topic_options(options), payload, publish_options(options))
      end

      private

      def publish_options(options)
        {
          delayed: options[:delayed]&.find { |name| name == @event },
          model: options[:enveloped] && options[:model],
          event: options[:enveloped] && @event
        }
      end

      def topic_options(options)
        {
          name: [TOPIC_EVENT_PREFIX, options[:model]].join('_'),
          prefix: ENV[TOPIC_PREFIX_ENV],
          environment: ENV[TOPIC_ENVIRONMENT_ENV],
          suffix: @event
        }
      end
    end
  end
end
