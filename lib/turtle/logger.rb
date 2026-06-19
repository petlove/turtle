# frozen_string_literal: true

require 'logger'
require 'time'

module Turtle
  module Logger
    PROGRAM_NAME = 'Turtle'
    LOG_LEVEL_ENV = 'TURTLE_LOGGER_LEVEL'
    DEFAULT_LEVEL = ::Logger::DEBUG

    class << self
      def debug(message)
        logger.debug(message)
      end

      def info(message)
        logger.info(message)
      end

      def error(message)
        logger.error(message)
      end

      def log_info(message)
        log('INFO', message)
      end

      def log_error(message)
        log('ERROR', message)
      end

      def logger
        @logger ||= build_logger
      end

      # Resets the memoized logger so that a new one is built lazily. Useful
      # when the log level or output device changes at runtime.
      def reset!
        @logger = nil
      end

      private

      def build_logger
        ::Logger.new($stdout).tap do |logger|
          logger.progname = PROGRAM_NAME
          logger.level = level
          logger.formatter = formatter
        end
      end

      def level
        ENV.fetch(LOG_LEVEL_ENV, nil)&.then { |value| parse_level(value) } || DEFAULT_LEVEL
      end

      def parse_level(value)
        ::Logger::Severity.const_get(value.to_s.upcase)
      rescue NameError
        DEFAULT_LEVEL
      end

      def formatter
        proc do |severity, time, progname, message|
          "#{log_line(severity, time, progname, message)}\n"
        end
      end

      def log_line(severity, time, progname, message)
        "[#{time.iso8601}] [#{progname}] #{severity} -- : #{message}"
      end

      def log(severity_level, message)
        "[#{Time.now.iso8601}] [#{PROGRAM_NAME}] #{severity_level} -- : #{message}"
      end
    end
  end
end
