
require 'bixby/modules/scheduler/driver'
require 'bixby/modules/scheduler/job'

module Bixby
class Scheduler

  class Job
    include ::Sidekiq::Worker
    def perform(*args)
      self.class.perform(*args)
    end
  end

  class Sidekiq < Driver

    class << self

      def configure(config)
        if config.include? :redis then

          server = config[:redis]
          if server !~ %r{^redis://} then
            server = "redis://#{server}"
          end

          ::Sidekiq.configure_server do |config|
            config.redis = { :url => server }
            config.poll_interval = 5
          end

          # When in Unicorn, this block needs to go in unicorn's `after_fork` callback:
          ::Sidekiq.configure_client do |config|
            config.redis = { :url => server }
          end
        end
      end

      def schedule_at_with_queue(timestamp, job, queue="schedules")
        # Sidekiq::Client.push('queue' => 'my_queue', 'class' => MyWorker, 'args' => ['foo', 1, :bat => 'bar'])
        args = {
          'queue' => queue,
          'class' => job.class,
          'args'  => job.queue_args,
          'retry' => true # TODO make configurable? necessary?
        }

        timestamp = timestamp.to_i
        if timestamp > (Time.new.to_i+1) then
          args['at'] = timestamp
        end
        ::Sidekiq::Client.push(args)
      end

    end

  end

end # Scheduler
end # Bixby

Bixby::Scheduler.drivers << Bixby::Scheduler::Sidekiq
