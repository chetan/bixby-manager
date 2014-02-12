
class Monitoring::BaseController < UiController

  # /monitoring
  def index

    bootstrap CheckTemplate.where(:org_id => current_user.org_id), :type => CheckTemplate

    oncalls = OnCall.where(:org_id => current_user.org_id)
    bootstrap oncalls, :type => OnCall

    users = User.where(:org_id => current_user.org_id)
    bootstrap users, :type => User
  end

end
