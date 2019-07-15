module Turtle
  module EventNotificator
    class State < Event
      def match?(before, after)
        before && after && before[:state] != @name.to_s && after[:state] == @name.to_s
      end
    end
  end
end
