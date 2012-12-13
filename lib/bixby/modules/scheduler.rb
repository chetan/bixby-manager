
module Bixby
class Scheduler < API

  class << self

    # Fetch the list of available drivers
    #
    # @return [Array<Class>] list of drivers
    def drivers
      @drivers ||= []
    end

    # Fetch the active driver
    #
    # @return [Bixby::Scheduler::Driver] driver class
    def driver
      return @driver if @driver
      if @drivers.empty? then
        raise "No available drivers!"
      end
      @driver = @drivers.last
    end

    # Set the active driver
    #
    # @param [Bixby::Scheduler::Driver] driver class
    def driver=(new_driver)
      @driver = new_driver
    end

    # Configure the active driver
    #
    # @param [Hash] config
    def configure(config)
      driver.configure(config)
    end

  end

  # Fetch the active driver
  #
  # @return [Bixby::Scheduler::Driver] driver instance
  def driver
    self.class.driver
  end

  # Schedule a job to start N seconds from now
  #
  # @param [Fixnum] time_in_sec   Number of seconds in future
  # @param [Bixby::Scheduler::Job] job  Job to schedule
  def schedule_in(time_in_sec, job)
    schedule_at_with_queue((Time.new + time_in_sec), job)
  end

  # Schedule a job to start N seconds from now, using a custom queue
  #
  # @param [Fixnum] time_in_sec         Number of seconds in future
  # @param [Bixby::Scheduler::Job] job  Job to schedule
  # @param [String] queue               Custom queue name
  def schedule_in_with_queue(time_in_sec, job, queue="schedules")
    schedule_at_with_queue((Time.new + time_in_sec), job, queue)
  end

  # Schedule a job to start at the given timestamp
  #
  # @param [Fixnum] timestamp           Timestamp or Time object to start at
  # @param [Bixby::Scheduler::Job] job  Job to schedule
  def schedule_at(timestamp, job)
    schedule_at_with_queue(timestamp, job)
  end

  # Schedule a job to start at the given timestamp, using a custom queue
  #
  # @param [Fixnum] timestamp           Timestamp or Time object to start at
  # @param [Bixby::Scheduler::Job] job  Job to schedule
  # @param [String] queue               Custom queue name
  def schedule_at_with_queue(timestamp, job, queue="schedules")
    driver.schedule_at_with_queue(timestamp, job, queue)
  end

end # Scheduler
end # Bixby

require 'bixby/modules/scheduler/driver'
require 'bixby/modules/scheduler/job'
require 'bixby/modules/scheduler/resque' if Bixby::Scheduler.drivers.empty?
