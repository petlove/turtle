module Turtle
  module EventNotificator
    class Event
      attr_accessor :name

      def initialize(name)
        @name = name
      end

      def match?(_before, _after)
        raise NotImplementedError, 'You should implement the method match?'
      end

      def build_notification(before, after)
        Notification.new(@name) if match?(before, after)
      end
    end
  end
end
