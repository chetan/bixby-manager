
require 'helper'
require 'setup/mock_api_channel'

module Bixby
  module Test

    class ServerHandlerTest < Bixby::Test::TestCase
      def setup
        super
        @agent = FactoryGirl.create(:agent)
        @chan = MockAPIChannel.new
      end

      def teardown
        super
        AgentRegistry.agents.clear
        Sidekiq.redis{ |r| r.flushdb }
      end

      def test_connect
        id = SecureRandom.uuid
        json_req = JsonRequest.new("", "")
        signed_req = SignedJsonRequest.new(json_req, @agent.access_key, @agent.secret_key)
        connect_req = Bixby::WebSocket::Request.new(signed_req, id, "connect")

        Bixby::AgentRegistry.expects(:add).with(@agent, @chan).returns(true)

        # convert to string & back
        msg = Bixby::WebSocket::Message.from_wire(connect_req.to_wire)
        ret = ServerHandler.new(msg, @agent).connect(msg.json_request, @chan)

        refute_kind_of JsonResponse, ret

        Bixby::AgentRegistry.expects(:remove).with(@chan)
        ServerHandler.new(nil, nil).disconnect(@chan)
      end
    end

  end
end
