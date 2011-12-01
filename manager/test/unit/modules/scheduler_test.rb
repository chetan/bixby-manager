
require 'test_helper'

class SchedulerTest < ActiveSupport::TestCase

  test "require class" do
    require "modules/scheduler"
    assert Object.const_defined? :Scheduler
  end

  test "has default driver" do
    assert Scheduler.driver
    assert (Scheduler.driver == Scheduler::Resque)
  end

  test "schedule a job" do
    Resque.reset_delayed_queue
    Scheduler.schedule_at((Time.new+30), Scheduler::Job.new("foobar", {}))
    assert (Resque.redis.zcard("delayed_queue_schedule") == 1) # key is namespaced
  end

end
