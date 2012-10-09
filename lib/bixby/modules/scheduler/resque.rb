
require 'bixby/modules/scheduler/driver'

module Bixby
class Scheduler

  class Resque < Driver

    class << self

      def configure(config)
        if config.include? :redis then
          ::Resque.redis = config[:redis]
        end
      end

      def schedule_at_with_queue(timestamp, job, queue="schedules")
        ::Resque.enqueue_at_with_queue(queue, timestamp, job.class, *job.queue_args)
      end

    end

  end

end # Scheduler
end # Bixby

Bixby::Scheduler.drivers << Bixby::Scheduler::Resque
