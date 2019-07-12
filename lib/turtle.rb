require 'turtle/version'
require 'turtle/queue'
require 'turtle/topic'
require 'turtle/logger'
require 'rails'

module Turtle
  class << self
    def shoryuken_queues_priorities(options = nil)
      Queue.shoryuken_priorities(options)
    end

    def delayed_job_queue_attributes
      Queue.delayed_job_queue_attributes.merge(Topic.delayed_job_queue_attributes)
    end

    def enqueue!(worker, data, options = {})
      Queue.enqueue!(worker, data, options)
    end

    def publish!(topic, data, options = {})
      Topic.publish!(topic, data, options)
    end

    def name_for(type, name, options = {})
      value = name_for_model(type, default_name_for_options.merge(name: name).merge(options))
      return unless value

      value.name_formatted
    end

    def retry_intervals
      [5.minutes, 15.minutes, 30.minutes, 1.hour, 3.hours, 12.hours]
    end

    private

    def name_for_model(type, options)
      case type
      when :queue
        AWS::SQS::Configurator::Queue.new(options)
      when :topic
        AWS::SNS::Configurator::Topic.new(options)
      end
    end

    def default_name_for_options
      { prefix: ENV['APP_NAME'], environment: ENV['APP_ENV'] }
    end
  end
end
