# frozen_string_literal: true

require 'logger'
require 'time'

module AWS
  module SNS
    module Configurator
      module Logger
        PROGRAM_NAME = 'AWS::SNS::Configurator'
        LOGGER_ENABLED_ENV = ENV.fetch('AWS_SNS_CONFIGURATOR_LOGGER', 'true')
        LOG_LEVEL_ENV = 'AWS_SNS_CONFIGURATOR_LOGGER_LEVEL'
        DEFAULT_LEVEL = ::Logger::DEBUG

        class << self
          def debug(message)
            logger.debug(message) if log?
          end

          def info(message)
            logger.info(message) if log?
          end

          def error(message)
            logger.error(message) if log?
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

          def reset!
            @logger = nil
          end

          private

          def log?
            LOGGER_ENABLED_ENV != 'false'
          end

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
              "[#{time.iso8601}] [#{progname}] #{severity} -- : #{message}\n"
            end
          end

          def log(severity_level, message)
            "[#{Time.now.iso8601}] [#{PROGRAM_NAME}] #{severity_level} -- : #{message}"
          end
        end
      end
    end
  end
end
