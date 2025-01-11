# frozen_string_literal: true

module AWS
  module SNS
    module Configurator
      class Subscriber
        attr_accessor :topic, :protocol, :endpoint, :options

        def initialize(topic, protocol, endpoint, options)
          @protocol = protocol
          @endpoint = endpoint
          @options = options

          build_topic(topic)
        end

        def subscribe!
          @topic.subscribe!(@protocol, @endpoint, @options).tap { log }
        end

        private

        def log
          Logger.info("Endpoint subscribed: #{@endpoint} -> #{@topic.name_formatted} - #{@topic.region}")
        end

        def build_topic(topic)
          @topic = Topic.new(topic)
        end
      end
    end
  end
end
