
class Monitoring::ActionsController < Monitoring::BaseController

  def new
    bootstrap Host.find(_id(:host_id))
    bootstrap Trigger.find(_id(:trigger_id))

    oncalls = OnCall.where(:org_id => current_user.org_id)
    bootstrap oncalls, :type => OnCall

    users = User.where(:org_id => current_user.org_id)
    bootstrap users, :type => User
  end

end
