# frozen_string_literal: true

require 'logger'
require 'turtle/version'
require 'turtle/group'
require 'turtle/queue'
require 'turtle/topic'
require 'turtle/logger'
require 'turtle/event_notificator'
require 'turtle/event_notificator/notification'
require 'turtle/event_notificator/event'
require 'turtle/event_notificator/state'
require 'turtle/event_notificator/action'
require 'turtle/railtie' if defined?(Rails::Railtie) && defined?(Shoryuken)

module Turtle
  class << self
    attr_writer :logger

    def logger
      @logger || build_default_logger
    end

    def logger_set?
      !@logger.nil?
    end

    def shoryuken_queues_priorities(options = nil)
      queues_in_groups = Group.to_h.values.flat_map { |attrs| attrs[:queues].map { |name, _| name } }
      Queue.shoryuken_priorities(options).reject { |name, _| queues_in_groups.include?(name) }
    end

    def shoryuken_groups
      Group.to_json
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
      [300, 900, 1800, 3600, 10_800, 43_200]
    end

    private

    def build_default_logger
      return ::Rails.logger if defined?(::Rails) && ::Rails.logger

      ::Logger.new($stdout)
    end

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
