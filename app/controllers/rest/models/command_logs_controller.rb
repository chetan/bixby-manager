
class Rest::Models::CommandLogsController < Rest::BaseController
  def index
    CommandLog.for_user(current_user).includes(:command, :agent, :user)
  end
end
