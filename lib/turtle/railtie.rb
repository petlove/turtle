# frozen_string_literal: true

module Turtle
  class Railtie < ::Rails::Railtie
    config.before_initialize do
      overwrite_eager_load

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

    # Set rails eager_load to true when running shoryuken in a rails project.
    # This is needed because otherwise workers show the message "No worker found" when trying to process messages
    # received from a topic.
    #
    # Messages enqueued using perform_async are not affected because they contain metadata informing the class name,
    # as can be seen at:
    # https://github.com/ruby-shoryuken/shoryuken/blob/546e4b81afbbacdc7ed6d742a96025be4616f292/lib/shoryuken/worker/default_executor.rb#L7-L10
    #
    # However, the code below used to define which worker to use only works when perform_async above is used.
    # https://github.com/ruby-shoryuken/shoryuken/blob/546e4b81afbbacdc7ed6d742a96025be4616f292/lib/shoryuken/default_worker_registry.rb#L15-L28
    #
    # Therefore the following code is needed.

    def overwrite_eager_load
      # $PROGRAM_NAME returns the name of the script being executed, i.e. "/usr/local/bundle/bin/shoryuken"
      return if $PROGRAM_NAME.to_s.split('/').last.downcase != 'shoryuken'
      return unless defined?(::Rails)
      return if ::Rails.application.config.eager_load == true

      Logger.info('Shoryuken and rails detected, overwriting ::Rails.application.config.eager_load to true')
      ::Rails.application.config.eager_load = true
    end
  end
end
