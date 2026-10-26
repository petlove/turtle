# frozen_string_literal: true

module AWS
  module SNS
    module Configurator
      module Logger
        LOGGER_ENABLED_ENV = 'AWS_SNS_CONFIGURATOR_LOGGER'

        class << self
          def info(message)
            return ::Turtle.logger.info(message) if ::Turtle.logger_set?

            puts message if log?
          end

          def error(message)
            return ::Turtle.logger.error(message) if ::Turtle.logger_set?

            puts message if log?
          end

          private

          def log?
            ENV[LOGGER_ENABLED_ENV] != 'false'
          end
        end
      end
    end
  end
end
