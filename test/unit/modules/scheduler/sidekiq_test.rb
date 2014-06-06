
require 'helper'

require 'bixby/modules/scheduler/sidekiq'
require 'setup/sidekiq_mock_redis'

# helper for testing actual perform() method
require "sidekiq/testing/inline"

module Bixby::Test::Modules::SchedulerDrivers
  class SidekiqDriver < Bixby::Test::TestCase

    class Foobar
      def baz(params)
      end
    end

    def setup
      super
      Bixby::Scheduler.driver = Bixby::Scheduler::Sidekiq
      Bixby::Scheduler.configure(BIXBY_CONFIG)
      @job = Bixby::Scheduler::Job.create(Foobar, :baz, nil)
    end

    def teardown
      super
      toggle_inline_testing(false)
      Sidekiq.redis{ |r| r.flushdb }
    end

    def test_schedule_at
      Sidekiq::Client.any_instance.expects(:raw_push).once().with{ |normed, payload|
        (normed["at"] <= Time.new.to_i+30) && normed["class"] == "Bixby::Scheduler::Job"
      }
      Bixby::Scheduler.new.schedule_at((Time.new+30), @job)
    end

    def test_schedule_in
      Bixby::Scheduler.new.schedule_in(30, @job)
      Sidekiq.redis{ |r| assert r.exists("schedule") }
    end

    def test_schedule_immediately
      Bixby::Scheduler.new.schedule_in(0, @job)
      Sidekiq.redis{ |r|
        refute r.exists("schedule")
        assert r.exists("queues")
      }
    end

    def test_schedule_in_with_queue
      Bixby::Scheduler.new.schedule_in_with_queue(30, @job, "foo")
      Sidekiq.redis{ |r| assert r.exists("schedule") }
    end

    def test_job_perform
      toggle_inline_testing(true)
      Foobar.any_instance.expects(:baz).once().with{ |params|
        params.kind_of?(Hash) && params["hello"] == "world"
      }
      Bixby::Scheduler.new.schedule_in(0, Bixby::Scheduler::Job.create(Foobar, :baz, {:hello => "world"}))
    end

    def test_recurring_job
      args = [ 30, Foobar.to_s, :baz, {:hello => "world" } ]
      Foobar.any_instance.expects(:baz).once().with{ |params|
        params.kind_of?(Hash) && params[:hello] == "world"
      }
      Bixby::Scheduler.any_instance.expects(:schedule_in).once().with { |interval, job|
        interval == 30 && job.klass = Foobar && job.method.to_s == "baz"
      }
      Bixby::Scheduler::RecurringJob.perform(*args)
    end

    def test_models_passed_via_id
      toggle_inline_testing(true)
      agent = FactoryGirl.create(:agent)
      Foobar.any_instance.expects(:baz).once().with{ |params|
        params.kind_of?(Agent) && params.id == agent.id
      }
      Bixby::Scheduler.new.schedule_in(0, Bixby::Scheduler::Job.create(Foobar, :baz, agent))
    end


    private

    def toggle_inline_testing(enabled=true)
      if enabled then
        Sidekiq::Testing.inline!
      else
        Sidekiq::Testing.disable!
      end
    end

  end
end
