
class Runbooks::ScheduledCommandsController < Runbooks::BaseController

  # /runbooks/scheduled_commands
  def index
    bootstrap ScheduledCommand.for_user(current_user).
      select("*, coalesce(completed_at, deleted_at, updated_at) AS sort_ts").
      where("(schedule_type = 1 AND enabled = ?) or (schedule_type = 2 AND completed_at IS NULL)", true).
      order("sort_ts DESC")
  end

  def history
    ScheduledCommand.with_deleted do
      bootstrap ScheduledCommand.for_user(current_user).
          select("*, coalesce(completed_at, deleted_at, updated_at) as sort_ts").
          where("(schedule_type = 2 AND (completed_at IS NOT NULL OR deleted_at IS NOT NULL)) OR (schedule_type = 1 AND enabled = ?)", false).
          order("sort_ts DESC"),
        :type => "ScheduledCommandHistory", :name => "scheduled_commands"
    end
  end

  def show
    sc = ScheduledCommand.find(_id)
    bootstrap sc

    if sc.cron? then
      # also need logs for this command
      logs = CommandLog.for_user(current_user).
        where(:scheduled_command_id => sc.id).
        includes(:command, :agent, :user).
        limit(10)
      bootstrap logs, :type => "ScheduledCommandLog"
    end
  end

end
