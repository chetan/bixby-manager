
class Rest::Models::OnCallsController < UiController

  def index
    @oncalls = OnCall.where(:org_id => current_user.org_id)
    restful @oncalls
  end

  def show
    oncall = OnCall.find(_id)
    restful @host
  end

  def update
  end

  def destroy
  end

end
