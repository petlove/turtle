# frozen_string_literal: true

module AWS
  module SNS
    module Configurator
      class Publisher
        attr_accessor :topic, :message

        def initialize(topic, message)
          @message = message

          build_topic(topic)
        end

        def publish!
          @topic.publish!(@message).tap { log }
        end

        private

        def log
          Logger.info("Message published: #{@endpoint} -> #{@topic.name_formatted} - #{@topic.region}")
        end

        def build_topic(topic)
          @topic = Topic.new(topic)
        end
      end
    end
  end
end
