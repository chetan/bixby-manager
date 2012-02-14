
# require 'test_helper'

class SchedulerTest < ActiveSupport::TestCase

  test "require class" do
    require "modules/scheduler"
    assert Object.const_defined? :Scheduler
  end

  test "has default driver" do
    assert Scheduler.driver
    assert (Scheduler.driver == Scheduling::Resque)
  end

  test "schedule a job" do
    Resque.reset_delayed_queue
    Scheduler.new.schedule_at((Time.new+30), Scheduling::Job.new("foobar", {}))
    assert (Resque.redis.zcard("delayed_queue_schedule") == 1) # key is namespaced
  end

end
