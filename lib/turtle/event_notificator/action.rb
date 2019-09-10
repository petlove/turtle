# frozen_string_literal: true

module Turtle
  module EventNotificator
    class Action < Event
      def match?(before, after)
        before && after && (before[:action] == @name || after[:action] == @name)
      end
    end
  end
end
