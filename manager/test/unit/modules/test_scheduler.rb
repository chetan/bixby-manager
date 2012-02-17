
# require 'test_helper'

class SchedulerTest < ActiveSupport::TestCase

  def test_require_class
    require "modules/scheduler"
    assert Object.const_defined? :Scheduler
  end

  def test_has_default_driver
    assert Scheduler.driver
    assert Scheduler.driver == Scheduling::Resque
  end

  def test_schedule_a_job
    Resque.reset_delayed_queue
    Scheduler.new.schedule_at((Time.new+30), Scheduling::Job.new("foobar", {}))
    assert Resque.redis.zcard("delayed_queue_schedule") == 1 # key is namespaced
  end

  def test_driver_must_override_methods
    assert_throws(NotImplementedError) do
      FooDriver.configure(nil)
    end
    assert_throws(NotImplementedError) do
      FooDriver.schedule_at_with_queue(nil, nil)
    end
  end

  class FooDriver < Scheduling::Driver
  end

end
