require 'turtle/version'
require 'turtle/queue'
require 'turtle/topic'
require 'turtle/logger'

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
  end
end
