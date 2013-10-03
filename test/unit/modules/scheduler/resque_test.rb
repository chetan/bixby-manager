
require 'helper'

class Bixby::Test::Modules::Scheduler < Bixby::Test::TestCase
  class ResqueDriver < Bixby::Test::TestCase

    def setup
      super
      Bixby::Scheduler.driver = Bixby::Scheduler::Resque
      Bixby::Scheduler.configure(BIXBY_CONFIG)
      Resque.redis = MockRedis.new
    end

    def teardown
      super
      Resque.redis.flushdb
    end

    def test_schedule_at
      Bixby::Scheduler.new.schedule_at((Time.new+30), Bixby::Scheduler::Job.create("foobar", {}))
      assert Resque.redis.exists "delayed_queue_schedule"
      assert_equal 1, Resque.redis.zcard("delayed_queue_schedule") # key is namespaced
    end

    def test_schedule_in
      Bixby::Scheduler.new.schedule_in(30, Bixby::Scheduler::Job.create("foobar", {}))
      assert_equal 1, Resque.redis.zcard("delayed_queue_schedule") # key is namespaced
    end

    def test_schedule_in_with_queue
      Bixby::Scheduler.new.schedule_in_with_queue(30, Bixby::Scheduler::Job.create("foobar", {}), "foo")
      assert_equal 1, Resque.redis.zcard("delayed_queue_schedule") # key is namespaced
    end

  end
end
