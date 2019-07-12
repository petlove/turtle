require 'aws/sns/configurator'

module Turtle
  class Topic
    DELAYED_JOB_QUEUE_PREFIX = 'topic'.freeze

    class << self
      def delayed_job_queue_attributes
        delayed_job_queue_attributes_by_topics(list)
      end

      def publish!(topic, data, options)
        initial = Time.now
        notify!(topic, envelope(data, options), options).tap do
          Logger.info(enqueued_log_message(topic, options, Time.now - initial))
        end
      end

      private

      def enqueued_log_message(topic, options, spent)
        "Published: #{topic} Delay: #{delay?(options)} Spent: #{spent}"
      end

      def notify!(topic, data, options)
        handled_topic(topic, options).publish!(topic, data)
      end

      def envelope(data, options)
        options[:event] || options[:model] ? { model: options[:model], event: options[:event], data: data } : data
      end

      def handled_topic(topic, options)
        delay?(options) ? delayed_topic(topic) : AWS::SNS::Configurator
      end

      def delayed_topic(topic)
        AWS::SNS::Configurator.delay(queue: delayed_job_queue_topic(topic))
      end

      def delay?(options)
        !(!options[:delay] || !AWS::SNS::Configurator.respond_to?(:delay))
      end

      def list
        AWS::SNS::Configurator.topics!
      end

      def delayed_job_queue_attributes_by_topics(topics)
        topics.each_with_object({}) do |topic, object|
          object[delayed_job_queue_topic(topic.name_formatted).to_sym] = delayed_job_attributes_by_topic(topic)
        end
      end

      def delayed_job_attributes_by_topic(topic)
        { priority: topic.metadata[:priority] || 1 }
      end

      def delayed_job_queue_topic(name_formatted)
        name_formatted = name_formatted[:name] if name_formatted.is_a?(Hash)

        "#{DELAYED_JOB_QUEUE_PREFIX}_#{name_formatted}"
      end
    end
  end
end
