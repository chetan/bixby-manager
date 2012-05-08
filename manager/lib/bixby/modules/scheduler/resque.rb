
require 'bixby/modules/scheduler/driver'

class Scheduler

  class Resque < Scheduling::Driver

    class << self

      def configure(config)
        if config.include? :redis then
          ::Resque.redis = config[:redis]
        end
      end

      def schedule_at_with_queue(timestamp, job, queue="schedules")
        ::Resque.enqueue_at_with_queue(queue, timestamp, job.name, job.args)
      end

    end

  end

end

Bixby::Scheduler.drivers << Bixby::Scheduler::Resque
