
require 'test_helper'

# helper for testing actual perform() method
require "sidekiq/testing/inline"
Sidekiq::Client.singleton_class.class_eval do
  alias_method :raw_push_inline, :raw_push
  alias_method :raw_push, :raw_push_old
end

class Bixby::Test::Modules::Scheduler < Bixby::Test::TestCase
  class SidekiqDriver < Bixby::Test::TestCase

    class Foobar
      def baz(params)
      end
    end

    def setup
      super
      Bixby::Scheduler.driver = Bixby::Scheduler::Sidekiq
      Bixby::Scheduler.configure(BIXBY_CONFIG)
    end

    def teardown
      super
      toggle_inline_testing(false)
      ::Resque.redis.flushdb
    end

    def test_schedule_at
      Sidekiq::Client.expects(:raw_push).once().with{ |normed, payload|
        (normed["at"] <= Time.new.to_i+30) && normed["class"] == "Bixby::Scheduler::Job"
      }
      Bixby::Scheduler.new.schedule_at((Time.new+30), Bixby::Scheduler::Job.create("foobar", {}))
    end

    def test_schedule_in
      Bixby::Scheduler.new.schedule_in(30, Bixby::Scheduler::Job.create("foobar", {}))
      Sidekiq.redis{ |r| assert r.exists("schedule") }
    end

    def test_schedule_immediately
      Bixby::Scheduler.new.schedule_in(0, Bixby::Scheduler::Job.create("foobar", {}))
      Sidekiq.redis{ |r|
        refute r.exists("schedule")
        assert r.exists("queues")
      }
    end

    def test_schedule_in_with_queue
      Bixby::Scheduler.new.schedule_in_with_queue(30, Bixby::Scheduler::Job.create("foobar", {}), "foo")
      Sidekiq.redis{ |r| assert r.exists("schedule") }
    end

    def test_job_perform
      toggle_inline_testing(true)
      Foobar.any_instance.expects(:baz).once().with{ |params|
        params.kind_of?(Hash) && params["hello"] == "world"
      }
      Bixby::Scheduler.new.schedule_in(0, Bixby::Scheduler::Job.create(Foobar, :baz, {:hello => "world"}))
    end


    private

    def toggle_inline_testing(enabled=true)

      Sidekiq::Client.singleton_class.class_eval do
        if enabled then
          alias_method :raw_push, :raw_push_inline
        else
          alias_method :raw_push, :raw_push_old # without inline
        end
      end

    end

  end
end
