
class Rest::Models::ChecksController < UiController

  def index
    @host = Host.find(params[:host_id])

    if params[:metric_id] then
      @ret = Metric.find(params[:metric_id].to_i).check
    else
      @ret = Check.where(:host_id => @host)
    end

    restful @ret
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

    check = Bixby::Monitoring.new.add_check(host, command, opts, agent)
    restful check
  end

end
