
module Bixby
class Scheduler

  class Driver

    class << self

      def configure(config)
        raise NotImplementedError.new("configure must be overridden!")
      end

      def schedule_at_with_queue(timestamp, job, queue="schedules")
        raise NotImplementedError.new("schedule_at_with_queue must be overridden!")
      end

    end

  end

end # Scheduler
end # Bixby
