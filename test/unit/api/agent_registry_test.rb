
require 'helper'
require 'setup/mock_api_channel'
require 'setup/sidekiq_mock_redis'

require "bixby/modules/scheduler"
require "bixby/modules/scheduler/sidekiq"

module Bixby
  module Test

    class AgentRegistryTest < Bixby::Test::TestCase

      def setup
        super
        @agent = FactoryGirl.create(:agent)
        @chan = MockAPIChannel.new
        Bixby::Scheduler.driver = Bixby::Scheduler::Sidekiq
      end

      def teardown
        super
        AgentRegistry.agents.clear
        Sidekiq.redis{ |r| r.flushdb }
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
        AgentRegistry.redis_channel.expects(:connected?).returns(true)
        assert AgentRegistry.add(@agent, @chan)
      end

    end

  end
end
