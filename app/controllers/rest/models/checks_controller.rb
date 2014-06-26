
class Rest::Models::ChecksController < ::Rest::ApiController

  def index
    host = Host.find(params[:host_id])

    if params[:metric_id] then
      ret = Metric.find(params[:metric_id].to_i).check
    else
      ret = Check.where(:host_id => host)
    end

    restful ret
  end

  def create
    # Parameters: {"command_id"=>1, "host_id"=>"3", "args"=>{"mount"=>"/"}}
    # optional param: "runhost_id" => 4

    host = Host.find(_id(:host))
    command = Command.find(_id(:command))
    opts = params[:args]

    agent = nil
    runhost_id = _id(:runhost, true)
    if runhost_id then
      agent = Host.find(runhost_id).agent
    end

    restful Bixby::Monitoring.new.add_check(host, command, opts, agent)
  end

  def show
    restful Check.find(_id)
  end

  def destroy
    check = Check.find(_id)
    check.destroy
    restful check.destroyed?
  end

  def update
    check = Check.find(_id)
    check.args = params[:args]

    host = Host.find(params[:runhost_id])

    check.agent_id = host.agent.id
    check.save

    restful check
  end

end
