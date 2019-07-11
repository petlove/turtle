# frozen_string_literal: true

module Turtle
  module Logger
    class << self
      def info(message)
        Rails.logger.info(log(message))
      end

      def error(message)
        Rails.logger.error(log(message))
      end

      private

      def log(message)
        "[Turtle] : #{message}"
      end
    end
  end
end
