
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

      scheduled_command.run_count += 1

      time_scheduled = scheduled_command.scheduled_at # preserve for alerting
      time_start = Time.new
      responses = []
      scheduled_command.agents.each do |agent|
        begin
          log.debug { "Executing scheduled command #{scheduled_command.id} on agent #{agent.id}" }
          res = Bixby::RemoteExec.new.exec(agent, scheduled_command.command_spec)
          res.log.scheduled_command_id = scheduled_command.id
          res.log.run_id = scheduled_command.run_count
          res.log.user_id = scheduled_command.created_by
          res.log.save
          responses << res

        rescue Exception => ex
          log.error { "Error while running scheduled command #{scheduled_command.id} on agent #{agent.id}" }
          log.error { "Will reschedule anyway" } if scheduled_command.cron?
          log.error { ex }
        end
      end

      time_end = Time.new
      log.debug { "Completed scheduled command #{scheduled_command.id} for all agents" }

      if scheduled_command.once? then
        scheduled_command.completed_at = time_end
      end

      # reschedule
      if scheduled_command.cron? then
        scheduled_command.update_next_run_time!
        scheduled_command.schedule_job!
      else
        scheduled_command.job_id = nil
      end

      logs = responses.map{ |r| r.log }
      success = logs.count{ |l| l.success? }

      # set status
      scheduled_command.last_run_at = time_start
      scheduled_command.last_run_status = if logs.size == success then
        1 # all passed
      elsif success == 0 then
        2 # all failed
      else
        3 # some failed
      end

      any_stdout = logs.count{ |l| !l.stdout.blank? } > 0
      any_stderr = logs.count{ |l| !l.stderr.blank? } > 0

      # Fire alerts if necessary
      success = (logs.size == success) # get a bool for testing alerts
      if (success && scheduled_command.alert_on_success?) ||                          # success
          (!success && scheduled_command.alert_on_error?) ||                          # error
          (scheduled_command.run_count <= 5 && scheduled_command.alert_on_first5?) || # first 5 runs
          (any_stdout && scheduled_command.alert_on_stdout?) ||                       # stdout
          (any_stderr && scheduled_command.alert_on_stderr?) ||                       # stderr
          ((any_stderr || any_stdout) && scheduled_command.alert_on_output?) then     # any output

        total_elapsed = time_end - time_start
        ScheduledCommandMailer.alert(scheduled_command, logs, time_scheduled, time_start, total_elapsed).deliver_later
      end

      scheduled_command.save
      true
    end

    def queue_args
      Job.serialize_args([@scheduled_command])
    end

  end

end
end
