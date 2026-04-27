# frozen_string_literal: true

require 'aws/sqs/configurator'
require 'yaml'
require 'erb'
require 'turtle/logger'

module Turtle
  class Group
    class << self
      def to_h
        @to_h ||= begin
          queues = AWS::SQS::Configurator.queues!
          config_groups.each_with_object({}) do |(name, attrs), groups|
            groups[name] = attrs.except(:queues).merge(queues: queue_list(Array(attrs[:queues]), queues))
            queue_names = groups[name][:queues].map(&:first).join(', ')
            Logger.info("Group added: #{name} concurrency: #{groups[name][:concurrency]} queues: #{queue_names}")
          end
        end
      end

      def to_json(*)
        to_h.to_json
      end

      private

      def config_groups
        merged = config_files.select { |f| File.exist?(f) }.each_with_object({}) do |file, groups|
          groups.merge!(YAML.safe_load(ERB.new(File.read(file)).result).to_h.fetch('groups', {}))
        end
        merged.transform_values { |attrs| attrs.transform_keys(&:to_sym) }
      end

      def config_files
        Dir[AWS::SQS::Configurator::Reader::DIR_FILES] << AWS::SQS::Configurator::Reader::MAIN_FILE
      end

      def queue_list(names, queues)
        queues.select { |q| names.include?(q.name) }
              .map { |q| [q.name_formatted, q.metadata[:priority] || 1] }
      end
    end
  end
end
