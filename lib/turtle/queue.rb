require 'aws/sqs/configurator'

module Turtle
  class Queue
    DELAYED_JOB_QUEUE_PREFIX = 'queue'.freeze

    class << self
      def shoryuken_priorities(options)
        shoryuken_priorities_by_queues(options ? filter_queues(list, options) : list)
      end

      def delayed_job_queue_attributes
        delayed_job_queue_attributes_by_queues(list)
      end

      def enqueue!(worker, data, options)
        initial = Time.now
        publish!(worker, envelope(data, options), options).tap do
          Logger.info(enqueued_log_message(worker, options, Time.now - initial))
        end
      end

      private

      def enqueued_log_message(worker, options, spent)
        "Enqueued: #{worker} Delayed: #{delayed?(worker, options)} Perform in: #{seconds(options)} Spent: #{spent}"
      end

      def publish!(worker, data, options)
        if seconds?(options)
          perform_in(handled_worker(worker, options), data, seconds(options))
        else
          perfom_async(handled_worker(worker, options), data)
        end
      end

      def envelope(data, options)
        return data unless options[:event] && options[:model]

        { model: options[:model], event: options[:event], data: data }
      end

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
        worker.delay(queue: worker)
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

      def delayed_job_queue_attributes_by_queues(queues)
        queues.each_with_object({}) do |queue, object|
          object[delayed_job_queue_name(queue)] = delayed_job_attributes_by_queue(queue)
        end
      end

      def delayed_job_attributes_by_queue(queue)
        { priority: queue.metadata[:priority] || 1 }
      end

      def delayed_job_queue_name(queue)
        "#{DELAYED_JOB_QUEUE_PREFIX}_#{queue.name_formatted}".to_sym
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
