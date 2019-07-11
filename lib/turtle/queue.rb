module Turtle
  class Queue
    class << self
      def priority
        priority_by_queues(list)
      end

      def priority_filtered(options)
        priority_by_queues(filter_queues(list, options))
      end

      def publish!(worker, payload, options = {})
        Logger.info("Worker: #{worker} Delayed: #{delayed?(worker, options)} Perform in: #{seconds(options)} seconds")
        if seconds?(options)
          perform_in(handled_worker(worker, options), payload, seconds(options))
        else
          perfom_async(handled_worker(worker, options), payload)
        end
      end

      private

      def seconds?(options)
        seconds(options) > 0
      end

      def seconds(options)
        options[:seconds].to_i
      end

      def handled_worker(worker, options)
        delayed?(worker, options) ? delayed_worker(worker) : worker
      end

      def delayed_worker(worker)
        worker.delay
      end

      def perform_in(worker, payload, seconds)
        worker.perform_in(seconds, payload)
      end

      def perfom_async(worker, payload)
        worker.perform_async(payload)
      end

      def delayed?(worker, options)
        !(!options[:delayed] || !worker.respond_to?(:delay))
      end

      def list
        AWS::SQS::Configurator.queues!
      end

      def filter_queues(queues, options)
        queues.select { |queue| options.all? { |key, value| queue.metadata[key] == value } }
      end

      def priority_by_queues(queues)
        queues.map { |queue| [queue.name_formatted, queue.metadata[:priority] || 1] }
      end
    end
  end
end
