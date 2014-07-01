
class Runbooks::BaseController < Repository::BaseController

  # /runbooks
  def index
    bootstrap Command.for_user(current_user), :type => Command
    bootstrap Host.for_user(current_user), :type => Host
  end

end
