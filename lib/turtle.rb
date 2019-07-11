require 'turtle/version'
require 'turtle/queue'
require 'turtle/logger'

module Turtle
  class << self
    def shoryuken_queues_priorities(options = nil)
      Queue.shoryuken_priorities(options)
    end
  end
end
