# frozen_string_literal: true

module Turtle
  module EventNotificator
    class ModelRequiredError < StandardError; end

    def self.included(base)
      base.send(:extend, ClassMethods)
    end

    module ClassMethods
      DEFAULT_ACTIONS = %i[create update destroy].freeze

      def act_as_notification(options)
        return if defined?(Rails) && Rails.env.test? && !ENV['TURTLE_TEST']
        raise ModelRequiredError unless options[:model]
        return unless available_events?(options)

        event_notificator_builders!(options)
      end

      private

      def event_notificator_builders!(options)
        initialize_event_notificator
        build_event_notificator_options!(options)
        build_event_notificator_before_callback!
        build_event_notificator_after_callback!
        build_event_notificator_after_touch_callback!
        build_event_notificator_notify!
      rescue StandardError
        nil
      end

      def available_events?(options)
        options[:states]&.any? || options[:actions]&.any?
      end

      def initialize_event_notificator
        send(:include, Turtle::EventNotificator::InstanceMethods)
        connection
      end

      def build_event_notificator_notify!
        send(:after_commit, lambda(&:event_notificator_notify!))
      end

      def build_event_notificator_before_callback!
        DEFAULT_ACTIONS.each do |action|
          send("before_#{action}", ->(base) { base.event_notificator_before_callback!(action) })
        end
      end

      def build_event_notificator_after_callback!
        DEFAULT_ACTIONS.each do |action|
          send("after_#{action}", ->(base) { base.event_notificator_after_callback!(action) })
        end
      end

      def build_event_notificator_after_touch_callback!
        send(:after_touch, lambda(&:save))
      end

      def build_event_notificator_options!(options)
        DEFAULT_ACTIONS.each do |action|
          send("before_#{action}", ->(base) { base.event_notificator_options!(options) })
        end
      end
    end

    module InstanceMethods
      attr_accessor :event_notificator_options, :event_notificator_events, :event_notificator_before_callback,
                    :event_notificator_after_callback, :event_notificator_notifications

      def event_notificator_options!(options)
        @event_notificator_notifications ||= []
        @event_notificator_options ||= default_event_notificator_options.merge(options)
        event_notificator_events!(options)
      end

      def event_notificator_before_callback!(action)
        @event_notificator_before_callback = build_event_notificator_callback(action)
      end

      def event_notificator_after_callback!(action)
        @event_notificator_after_callback = build_event_notificator_callback(action)
        create_event_notificator_notifications!
      end

      def event_notificator_notify!
        notifications = event_notificator_notifications.compact.uniq(&:event)
        return if notifications.empty?

        payload = build_event_notificator_payload
        notifications.each { |notification| notification.publish!(payload, @event_notificator_options) }
      ensure
        event_notificator_cleanup!
      end

      def __build_state_value__
        send("#{@event_notificator_options[:state_column]}_was")
      rescue StandardError
        nil
      end

      private

      def create_event_notificator_notifications!
        @event_notificator_notifications += @event_notificator_events.map do |event|
          build_event_notificator_notification_by_event(event)
        end
      end

      def build_event_notificator_payload
        return event_notificator_serializer unless @event_notificator_options[:serializer_root]

        event_notificator_serializer.as_json[@event_notificator_options[:serializer_root]]
      end

      def event_notificator_serializer
        @event_notificator_options[:serializer].new(self, @event_notificator_options[:serializer_options])
      end

      def build_event_notificator_notification_by_event(event)
        event.build_notification(@event_notificator_before_callback, @event_notificator_after_callback)
      end

      def build_event_notificator_callback(action)
        { state: __build_state_value__, action: event_notificator_action(action) }
      end

      def event_notificator_cleanup!
        @event_notificator_before_callback = nil
        @event_notificator_after_callback = nil
        @event_notificator_notifications = []
      end

      def event_notificator_events!(options)
        @event_notificator_events ||= build_event_notificator_state_events(options) +
                                      build_event_notificator_action_events(options)
      end

      def build_event_notificator_state_events(_options)
        build_event_notificator_event(@event_notificator_options[:states], State)
      end

      def build_event_notificator_action_events(_options)
        build_event_notificator_event(@event_notificator_options[:actions], Action)
      end

      def build_event_notificator_event(list, kind)
        list ? list.map { |item| kind.new(item) } : []
      end

      def event_notificator_action(action)
        {
          create: :created,
          update: :updated,
          destroy: :destroyed
        }[action]
      end

      def default_event_notificator_options
        {
          enveloped: true,
          serializer_options: {},
          states: [],
          state_column: :state,
          actions: [],
          delayed: []
        }
      end
    end
  end
end
