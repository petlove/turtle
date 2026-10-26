# frozen_string_literal: true

module Turtle
  module Logger
    def self.info(message)
      Turtle.logger.info(message)
    end

    def self.error(message)
      Turtle.logger.error(message)
    end
  end
end
