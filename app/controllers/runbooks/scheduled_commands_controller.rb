
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
      order(:created_at => :asc)
  end

  def show
    bootstrap ScheduledCommand.find(_id)
  end

end
