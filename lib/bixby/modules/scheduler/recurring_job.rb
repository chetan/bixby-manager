
module Bixby
class Scheduler

  class RecurringJob < Job
    attr_accessor :interval

    def self.create(interval, klass, method, args = [])
      job = super(klass, method, args)
      job.interval = interval
      return job
    end

    def self.perform(*args)

      interval = args.shift.to_i
      klass    = args.shift.constantize
      method   = args.shift

      begin
        log.debug { "Going to execute: #{klass}.#{method}" }
        klass.new.send(method, *args)
      rescue Exception => ex
        log.error { "Error while running job: #{klass}.#{method} with arguments: #{args}"}
        log.error { "Will reschedule anyway" }
        log.error { ex }
      end

      # reschedule
      job = RecurringJob.create(interval, klass, method, args)
      Scheduler.new.schedule_in(interval, job)
    end

    def queue_args
      [@interval, @klass.to_s, @method.to_s] + @args
    end

  end

end
end
