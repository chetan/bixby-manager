
require 'test_helper'

class Bixby::Test::Modules::Scheduler < Bixby::Test::TestCase

  def test_require_class
    require "bixby/modules/scheduler"
    require "bixby/modules/scheduler/sidekiq"
    assert Bixby.const_defined? :Scheduler
  end

  def test_has_default_driver
    assert Bixby::Scheduler.driver
  end

  def change_driver
    Bixby::Scheduler.driver = Bixby::Scheduler::Resque
    assert Bixby::Scheduler.driver == Bixby::Scheduler::Resque

    Bixby::Scheduler.driver = Bixby::Scheduler::Sidekiq
    assert Bixby::Scheduler.driver == Bixby::Scheduler::Sidekiq
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
