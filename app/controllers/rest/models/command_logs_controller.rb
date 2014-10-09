
class Rest::Models::CommandLogsController < Rest::BaseController
  def index
    logs = CommandLog.for_user(current_user).includes(:command, :agent, :user)

    # optionally filter by scheduled_command_id
    id = _id(:scheduled_command_id, true)
    if id then
      logs = logs.where(:scheduled_command_id => id)
    end

    logs
  end

  def show
    CommandLog.find(_id)
  end
end
