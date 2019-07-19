# frozen_string_literal: true

module Turtle
  module Logger
    LOGGER_ENABLED_ENV = 'TURTLE_LOGGER'.freeze

    class << self
      def info(message)
        puts log_info(message) if log?
      end

      def error(message)
        puts log_error(message) if log?
      end

      def log_info(message)
        log('INFO', message)
      end

      def log_error(message)
        log('ERROR', message)
      end

      private

      def log?
        ENV['TURTLE_LOGGER']
      end

      def log(severity_level, message)
        "[#{Time.now.iso8601}] [Turtle] #{severity_level} -- : #{message}"
      end
    end
  end
end
