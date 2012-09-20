
require 'test_helper'

class Bixby::Test::Modules::Scheduler < ActiveSupport::TestCase

  def setup
    SimpleCov.command_name 'test:modules:scheduler'
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
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
    Resque.reset_delayed_queue
    Bixby::Scheduler.new.schedule_at((Time.new+30), Bixby::Scheduler::Job.new("foobar", {}))
    assert Resque.redis.zcard("delayed_queue_schedule") == 1 # key is namespaced
  end

  def test_schedule_in
    Resque.reset_delayed_queue
    Bixby::Scheduler.new.schedule_in(30, Bixby::Scheduler::Job.new("foobar", {}))
    assert Resque.redis.zcard("delayed_queue_schedule") == 1 # key is namespaced
  end

  def test_schedule_in_with_queue
    Resque.reset_delayed_queue
    Bixby::Scheduler.new.schedule_in_with_queue(30, Bixby::Scheduler::Job.new("foobar", {}), "foo")
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

  class FooDriver < Bixby::Scheduler::Driver
  end

end
