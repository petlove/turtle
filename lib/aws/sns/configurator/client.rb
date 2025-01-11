# frozen_string_literal: true

module AWS
  module SNS
    module Configurator
      class Client
        attr_accessor :aws

        def initialize(region)
          @aws = Aws::SNS::Client.new({ region: region, endpoint: ENV['AWS_SQS_ENDPOINT'] }.compact)
        end
      end
    end
  end
end
