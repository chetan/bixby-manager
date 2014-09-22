
class Runbooks::LogsController < Runbooks::BaseController

  # /logs
  def index
    bootstrap CommandLog.for_user(current_user).includes(:command, :agent, :user).limit(25), :type => CommandLog
  end

end
