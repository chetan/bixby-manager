
# Stub out Bixby API calls to Agents
#
# usage:
#
#   def test_get_bundle
#     stub_api.expect{ |agent, op, params|
#       # verify that the call was the correct one, must return truthy value
#       params[:command] == "get_bundle.rb"
#     }.returns(JsonResponse.new("success")).times(2)
#     # can return either a JsonResponse or CommandResponse
#
#     # ... make call, etc ...
#
#     assert_api_requests
#   end

module Bixby

  class API

    include Micron::TestCase::Assertions

    class Stub
      attr_accessor :block, :response

      # Block which verifies the request. Must return a truthy value
      #
      # @yieldparam [Agent] agent
      # @yieldparam [String] op
      # @yieldparam [Hash] params
      #
      # @return [self]
      def expect(&block)
        @block = block
        self
      end

      # How to respond to the request
      #
      # @param [JsonResponse, CommandResponse] response
      #
      # @return[self]
      def returns(response)
        @response = response
        self
      end

      # Number of times this request is expected to be called
      #
      # @param [Fixnum] num
      #
      # @returns[self]
      def times(num)
        return if num == 1 # we expect 1 call by default
        num -= 1
        num.times do
          API.stubs << self.dup
        end
        self
      end

      # Test the expected response [internal method]
      #
      # @param [Call] call
      #
      # @return [Boolean] truthy value used in assertion
      def test(call)
        block.call(call.agent, call.operation, call.params)
      end

    end

    class Call
      attr_accessor :agent, :operation, :params

      def initialize(agent, operation, params)
        @agent     = agent
        @operation = operation

        # turn stdin back into a hash for easier testing
        p = params.dup
        p[:stdin] = MultiJson.load(p[:stdin]) if not p[:stdin].blank?
        @params    = p
      end

      def to_s
        "\tagent:\tid=#{agent.id.to_s}, host=#{agent.ip}:#{agent.port}" +
        "\n\toperation:\t" + operation +
        "\n\tparams:\n\t" + params.ai.gsub(/\n/, "\n\t")
      end
    end

    class << self
      include MiniTest::Assertions
      def stubs
        @stubs ||= []
      end
      def enable_stub_exec_api!
        alias_method :exec_api, :fake_exec_api
      end
      def disable_stub_exec_api!
        alias_method :exec_api, :real_exec_api
        stubs.clear
      end
      def stub
        enable_stub_exec_api!
        s = Stub.new
        stubs << s
        s
      end
    end

    # Replace the exec_api call with a version which uses our stubs/assertions
    # Returns Stub#response to the caller (of exec_api)
    def fake_exec_api(agent, operation, params)
      call = Call.new(agent, operation, params)
      stub = API.stubs.shift
      assert stub, "Unexpected API call (no response stub set)\n#{call}"
      assert stub.test(call), "Stub didn't match API call:\n#{call}"

      res = stub.response
      res = res.to_json_response if res.kind_of? CommandResponse
      logger.debug res
      return res
    end
    alias_method :real_exec_api, :exec_api # make a backup of the original method

  end # API

  class Test::TestCase

    # Shortcut for creating new API::Stub
    def stub_api
      Bixby::API.stub
    end

    # Install teardown method
    alias_method :teardown_without_api_stubs, :teardown
    def teardown_api_stubs
      teardown_without_api_stubs
      Bixby::API.disable_stub_exec_api!
    end
    alias_method :teardown, :teardown_api_stubs

    # Assert that there no remaining API stubs (calls not made)
    def assert_api_requests
      assert Bixby::API.stubs.empty?, "Not all expected API calls were made! #{Bixby::API.stubs.size} stubs left"
    end

  end # Test::TestCase

end # Bixby
