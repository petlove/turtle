# frozen_string_literal: true

module Turtle
  class Railtie < ::Rails::Railtie
    config.before_initialize do
      if ENV['AWS_SQS_ENDPOINT'].present?
        Shoryuken.sqs_client = Aws::SQS::Client.new(
          endpoint: ENV['AWS_SQS_ENDPOINT']
        )

        Shoryuken.configure_client do |con|
          con.sqs_client = Aws::SQS::Client.new(
            endpoint: ENV['AWS_SQS_ENDPOINT']
          )
        end

        Shoryuken.configure_server do |con|
          con.sqs_client = Aws::SQS::Client.new(
            endpoint: ENV['AWS_SQS_ENDPOINT']
          )
        end
      end
    end
  end
end
