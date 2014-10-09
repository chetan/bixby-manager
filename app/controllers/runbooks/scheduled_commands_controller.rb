
class Runbooks::ScheduledCommandsController < Runbooks::BaseController

  # /runbooks/scheduled_commands
  def index
    bootstrap ScheduledCommand.for_user(current_user).
      where("schedule_type = 1 OR completed_at IS NULL").
      order(:created_at => :asc)
  end

  def history
    bootstrap ScheduledCommand.for_user(current_user).
      where("schedule_type = 2 AND completed_at IS NOT NULL").
      order(:created_at => :asc), :type => "ScheduledCommandHistory"
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
