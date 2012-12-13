
require 'test_helper'

class Bixby::Test::Modules::Scheduler < Bixby::Test::TestCase
  class SidekiqDriver < Bixby::Test::TestCase

    def setup
      super
      Bixby::Scheduler.driver = Bixby::Scheduler::Sidekiq
      Bixby::Scheduler.configure(BIXBY_CONFIG)
    end

    def teardown
      super
      Resque.redis.flushdb
    end

    def test_schedule_at
      Bixby::Scheduler.new.schedule_at((Time.new+30), Bixby::Scheduler::Job.new("foobar", {}))
      Sidekiq.redis{ |r| assert r.exists("schedule") }
    end

    def test_schedule_in
      Bixby::Scheduler.new.schedule_in(30, Bixby::Scheduler::Job.new("foobar", {}))
      Sidekiq.redis{ |r| assert r.exists("schedule") }
    end

    def test_schedule_immediately
      Bixby::Scheduler.new.schedule_in(0, Bixby::Scheduler::Job.new("foobar", {}))
      Sidekiq.redis{ |r|
        refute r.exists("schedule")
        assert r.exists("queues")
      }
    end

    def test_schedule_in_with_queue
      Bixby::Scheduler.new.schedule_in_with_queue(30, Bixby::Scheduler::Job.new("foobar", {}), "foo")
      Sidekiq.redis{ |r| assert r.exists("schedule") }
    end

  end
end
