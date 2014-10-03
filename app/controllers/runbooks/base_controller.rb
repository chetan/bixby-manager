
class Runbooks::BaseController < UiController

  # /runbooks
  def index
    bootstrap Command.for_user(current_user), :type => Command
    bootstrap Host.for_user(current_user), :type => Host
    bootstrap User.where(:org_id => current_user.org_id), :type => User
  end

end
