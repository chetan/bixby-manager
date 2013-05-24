
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

    host = Host.find(params[:host_id])
    command = Command.find(params[:command_id])
    opts = params[:args]

    check = Bixby::Monitoring.new.add_check(host, command, opts)
    restful check
  end

end
