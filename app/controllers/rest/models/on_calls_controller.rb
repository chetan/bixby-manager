
class Rest::Models::OnCallsController < ::Rest::ApiController

  def index
    restful OnCall.where(:org_id => current_user.org_id)
  end

  def show
    restful OnCall.find(_id)
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

    attrs[:users] = params[:users].split(/,/).map{ |u| u.to_i }
    attrs[:current_user_id] = attrs[:users].first

    oncall.update_attributes(attrs)

    restful oncall
  end

  def update
  end

  def destroy
  end

end
