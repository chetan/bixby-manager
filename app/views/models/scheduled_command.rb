
module Bixby
  module ApiView
    class ScheduledCommand < ::ApiView::Base

      for_model ::ScheduledCommand
      attrs :id, :agent_ids, :command_id, :created_by, :stdin, :args, :env,
            :schedule_type, :schedule, :scheduled_at,
            :alert_on, :alert_users, :alert_emails,
            :created_at, :updated_at, :completed_at, :deleted_at,
            :run_count, :enabled

      def convert
        super
        self[:org]   = obj.org.name
        self[:host_ids] = obj.agents.includes(:host).map { |a| a.host.id }
        self[:hosts] = obj.agents.includes(:host).map { |a| a.host.name }
        self[:owner] = obj.owner.name
        self[:command] = obj.command.display_name

        # extra info
        last_run = obj.last_run
        if last_run then
          self[:last_run_log] = render(last_run)
          self[:last_run]     = last_run.requested_at
          self[:status]       = last_run.success? ? "success" : "fail"
        end
        if obj.cron? || !last_run then
          self[:next_run] = obj.scheduled_at
        end

        self
      end

    end
  end
end
