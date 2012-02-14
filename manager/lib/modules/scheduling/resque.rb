
require 'modules/scheduling/driver'

module Scheduling

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

Scheduler.drivers << Scheduling::Resque
