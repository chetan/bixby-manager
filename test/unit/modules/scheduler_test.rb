
require 'test_helper'

class Bixby::Test::Modules::Scheduler < Bixby::Test::TestCase

  def setup
    super
    Resque.reset_delayed_queue
  end

  def teardown
    super
    Resque.reset_delayed_queue
  end

  def test_require_class
    require "bixby/modules/scheduler"
    assert Bixby.const_defined? :Scheduler
  end

  def test_has_default_driver
    assert Bixby::Scheduler.driver
    assert Bixby::Scheduler.driver == Bixby::Scheduler::Resque
  end

  def test_schedule_at
    Bixby::Scheduler.new.schedule_at((Time.new+30), Bixby::Scheduler::Job.new("foobar", {}))
    assert_equal 1, Resque.redis.zcard("delayed_queue_schedule") # key is namespaced
  end

  def test_schedule_in
    Bixby::Scheduler.new.schedule_in(30, Bixby::Scheduler::Job.new("foobar", {}))
    assert_equal 1, Resque.redis.zcard("delayed_queue_schedule") # key is namespaced
  end

  def test_schedule_in_with_queue
    Bixby::Scheduler.new.schedule_in_with_queue(30, Bixby::Scheduler::Job.new("foobar", {}), "foo")
    assert_equal 1, Resque.redis.zcard("delayed_queue_schedule") # key is namespaced
  end

  def test_driver_must_override_methods
    assert_throws(NotImplementedError) do
      FooDriver.configure(nil)
    end
    assert_throws(NotImplementedError) do
      FooDriver.schedule_at_with_queue(nil, nil)
    end
  end

  class FooDriver < Bixby::Scheduler::Driver
  end

end
