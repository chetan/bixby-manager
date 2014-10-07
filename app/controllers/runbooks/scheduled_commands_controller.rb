
class Runbooks::ScheduledCommandsController < Runbooks::BaseController

  # /runbooks/scheduled_commands
  def index
    bootstrap ScheduledCommand.for_user(current_user).order(:created_at => :asc),
                :type => ScheduledCommand
  end

end
