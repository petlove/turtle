require 'aws/sqs/configurator'

module Turtle
  class Queue
    class << self
      def shoryuken_priorities(options)
        shoryuken_priorities_by_queues(options ? filter_queues(list, options) : list)
      end

      private

      def list
        AWS::SQS::Configurator.queues!
      end

      def shoryuken_priorities_by_queues(queues)
        queues.map { |queue| [queue.name_formatted, queue.metadata[:priority] || 1] }
      end

      def filter_queues(queues, options)
        queues.select { |queue| options.all? { |key, value| queue.metadata[key] == value } }
      end
    end
  end
end
