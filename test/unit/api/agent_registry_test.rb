
require 'test_helper'
require 'setup/mock_api_channel'
require 'setup/sidekiq_mock_redis'

module Bixby
  module Test

    class AgentRegistryTest < Bixby::Test::TestCase

      def setup
        super
        @agent = FactoryGirl.create(:agent)
        @chan = MockAPIChannel.new
      end

      def teardown
        super
        AgentRegistry.agents.clear
        Sidekiq.redis{ |r| r.flushdb }
        BIXBY_CONFIG[:crypto] = false
        MultiTenant.current_tenant = nil
      end

      def test_add
        add()
        Sidekiq.redis{ |r| assert r.hexists("bixby:agents", @agent.id) }
      end

      def test_remove
        add()
        AgentRegistry.remove(@chan)
        Sidekiq.redis{ |r| refute r.hexists("bixby:agents", @agent.id) }
      end

      def test_get
        add()
        assert_equal @chan, AgentRegistry.get(@agent)
        assert_equal @chan, AgentRegistry.get(@agent.id)
      end

      def test_find
        add()
        assert_equal AgentRegistry.hostname, AgentRegistry.find(@agent)
        assert_equal AgentRegistry.hostname, AgentRegistry.find(@agent.id)
      end

      def test_hostname
        h = AgentRegistry.hostname
        assert_equal h, AgentRegistry.hostname # should always return same str
      end

      def test_redis_channel
        assert_kind_of RedisAPIChannel, AgentRegistry.redis_channel
      end



      private

      def add
        AgentRegistry.add(@agent, @chan)
      end

    end

  end
end

