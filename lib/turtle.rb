require 'turtle/version'
require 'turtle/queue'
require 'turtle/logger'

module Turtle
  class << self
    def queues_priority(options = nil)
      options ? Queue.priority_filtered(options) : Queue.priority
    end
  end
end
