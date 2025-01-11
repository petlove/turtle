# frozen_string_literal: true

module AWS
  module SNS
    module Configurator
      module Logger
        LOGGER_ENABLED_ENV = ENV.fetch('AWS_SNS_CONFIGURATOR_LOGGER', 'true')

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
            LOGGER_ENABLED_ENV != 'false'
          end

          def log(severity_level, message)
            "[#{Time.now.iso8601}] [AWS::SNS::Configurator] #{severity_level} -- : #{message}"
          end
        end
      end
    end
  end
end
