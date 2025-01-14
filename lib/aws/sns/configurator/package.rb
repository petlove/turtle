# frozen_string_literal: true

module AWS
  module SNS
    module Configurator
      class Package
        GENERAL_DEFAULT_OPTIONS = %i[region prefix suffix environment metadata].freeze
        GENERAL_DEFAULT_PATH = %i[default general].freeze
        TOPIC_DEFAULT_PATH = %i[default topic].freeze
        DEFAULT_CONTENT = { topics: [] }.freeze

        attr_accessor :content, :topics_options, :general_default_options, :topic_default_options

        def initialize(content)
          build_content!(content)
          build_topics_options!
          build_general_default_options!
          build_topic_default_options!
        end

        def unpack!
          @topics_options.map(&method(:build_topic!))
        end

        private

        def build_content!(content)
          @content = DEFAULT_CONTENT.merge(content || {})
        end

        def build_topics_options!
          @topics_options = @content[:topics]
        end

        def build_general_default_options!
          @general_default_options = default_options(GENERAL_DEFAULT_PATH, GENERAL_DEFAULT_OPTIONS)
        end

        def build_topic_default_options!
          @topic_default_options = default_options(TOPIC_DEFAULT_PATH, GENERAL_DEFAULT_OPTIONS)
        end

        def default_options(path, fields)
          (@content&.dig(*path) || {}).slice(*fields)
        end

        def build_topic!(topic_options)
          Topic.new(build_topic_options(topic_options))
        end

        def build_topic_options(topic_options)
          general_default_options.merge(topic_default_options).merge(topic_options.compact)
        end
      end
    end
  end
end
