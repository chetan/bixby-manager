
require 'helper'
require 'setup/sidekiq_mock_redis'

module Bixby
  module Test

    class ServerHandlerTest < Bixby::Test::TestCase
      def setup
        super
        @agent = FactoryGirl.create(:agent)
      end

      def teardown
        super
        AgentRegistry.agents.clear
        Sidekiq.redis{ |r| r.flushdb }
        EM.stop_event_loop if EM.reactor_running?
      end

      def test_execute

        chan = Bixby::AgentRegistry.redis_channel

        host_key = "bixby:agents:exec:#{AgentRegistry.hostname}"

        redis = mock()
        EM::Hiredis::PubsubClient.stubs(:new).returns(redis)
        redis.stubs(:connect)
        redis.stubs(:subscribe).with(host_key)

        # Bixby::AgentRegistry.redis_channel.start!

        req = JsonRequest.new("foo", "bar")
        agent_id = @agent.id
        host = Bixby::AgentRegistry.hostname

        # make sure request gets published to redis
        Sidekiq.redis { |c|
          c.expects(:publish).with() { |key, data|
            d = MultiJson.load(data)
            key == host_key &&
              d["type"] == "rpc" &&
              d["headers"]["agent_id"] == 1 &&
              d["headers"]["reply_to"].include?(`hostname`.strip)
          }
        }

        id = chan.execute_async(req, agent_id, host)

        # send a response back
        chan.publish_response(id, "foobar")

        ret = chan.fetch_response(id)
        assert_equal "foobar", ret
      end


    end

  end
end
