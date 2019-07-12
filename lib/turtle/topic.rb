require 'aws/sns/configurator'

module Turtle
  class Topic
    DELAYED_JOB_QUEUE_PREFIX = 'topic'.freeze

    class << self
      def delayed_job_queue_attributes
        delayed_job_queue_attributes_by_topics(list)
      end

      private

      def list
        AWS::SNS::Configurator.topics!
      end

      def delayed_job_queue_attributes_by_topics(topics)
        topics.each_with_object({}) do |topic, object|
          object[delayed_job_queue_name(topic)] = delayed_job_attributes_by_topic(topic)
        end
      end

      def delayed_job_attributes_by_topic(topic)
        { priority: topic.metadata[:priority] || 1 }
      end

      def delayed_job_queue_name(topic)
        "#{DELAYED_JOB_QUEUE_PREFIX}_#{topic.name_formatted}".to_sym
      end
    end
  end
end
