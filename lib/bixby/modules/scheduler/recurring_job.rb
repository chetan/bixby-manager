
module Bixby
class Scheduler

  class RecurringJob < Job
    attr_accessor :interval

    # Create a new RecurringJob
    #
    # @param [Fixnum] interval        time in seconds between runs
    # @param [Class] klass            class which has the method we want to run
    # @param [Symbol] method          name of _instance_ method to call
    # @param [Array<Object>] args     array of arguments to pass to method
    #
    # @return [RecurringJob]
    def self.create(interval, klass, method, args = [])
      job = super(klass, method, args)
      job.interval = interval
      return job
    end

    def self.perform(*args)
      orig_args = args.dup

      interval = args.shift.to_i
      klass    = args.shift.constantize
      method   = args.shift

      begin
        log.debug { "Going to execute: #{klass}.#{method}" }
        klass.new.send(method, *deserialize_args(args))
      rescue Exception => ex
        log.error { "Error while running job: #{klass}.#{method} with arguments: #{args}"}
        log.error { "Will reschedule anyway" }
        log.error { ex }
      end

      # reschedule
      job = RecurringJob.create(interval, klass, method, orig_args)
      Scheduler.new.schedule_in(interval, job)
      true
    end

    def queue_args
      [@interval, @klass.to_s, @method.to_s] + @args
    end

  end

end
end
