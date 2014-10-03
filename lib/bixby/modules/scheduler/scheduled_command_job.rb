
module Bixby
class Scheduler

  class ScheduledCommandJob < Job
    attr_accessor :scheduled_command

    # Create a new RecurringJob
    #
    # @param [ScheduledCommand] scheduled_command
    #
    # @return [ScheduledCommandJob]
    def self.create(scheduled_command)
      job = new
      job.scheduled_command = scheduled_command
      return job
    end

    def self.perform(*args)
      args = deserialize_args(args)
      scheduled_command = args.shift

      responses = []

      scheduled_command.agents.each do |agent|
        begin
          log.debug { "Executing scheduled command #{scheduled_command.id} on agent #{agent.id}" }
          res = Bixby::RemoteExec.new.exec(agent, scheduled_command.command_spec)
          res.log.scheduled_command_id = scheduled_command.id
          res.log.save
          responses << res

        rescue Exception => ex
          log.error { "Error while running scheduled command #{scheduled_command.id} on agent #{agent.id}" }
          log.error { "Will reschedule anyway" } if scheduled_command.cron?
          log.error { ex }
        end
      end

      log.debug { "Completed scheduled command #{scheduled_command.id} for all agents" }

      if scheduled_command.once? then
        scheduled_command.completed_at = Time.new
        scheduled_command.save
      end

      # Fire alerts
      logs = responses.map{ |r| r.log }
      ScheduledCommandMailer.alert(scheduled_command, logs).deliver

      # reschedule
      if scheduled_command.cron? then
        scheduled_command.update_next_run_time!
        scheduled_command.schedule_job!
      end

      true
    end

    def queue_args
      Job.serialize_args([@scheduled_command])
    end

  end

end
end
