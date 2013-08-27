
module Bixby
  module Test

    class MockAPIChannel < Bixby::APIChannel

      class << self
        def requests
          @requests ||= []
        end
      end

      def execute(json_request)
        MockAPIChannel.requests << json_request
      end

    end

  end
end
