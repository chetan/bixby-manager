
class Rest::Models::OnCallsController < UiController

  def index
    @oncalls = OnCall.where(:org_id => current_user.org_id)
    restful @oncalls
  end

  def show
    oncall = OnCall.find(_id)
    restful @host
  end

  def create
    oncall = OnCall.new
    oncall.org_id = current_user.org_id
    attrs = pick(:name, :rotation_period, :handoff_day)

    # create handoff time
    h = _id(:handoff_hour)
    m = _id(:handoff_min)
    ts = "#{h}:#{m}"
    attrs[:handoff_time] = DateTime.parse(ts)

    attrs[:users] = params[:users].split(/,/)
    attrs[:current_user] = attrs[:users].first

    oncall.update_attributes(attrs)

    restful oncall
  end

  def update
  end

  def destroy
  end

end
