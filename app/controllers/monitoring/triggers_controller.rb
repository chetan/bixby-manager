
class Monitoring::TriggersController < Monitoring::BaseController

  # GET "/monitoring/hosts/3/triggers"
  def index
    @host = Host.find(params[:host_id])

    if params[:metric_id] then
      @ret = Metric.find(params[:metric_id].to_i).check
    else
      @ret = Check.where(:host_id => @host)
    end

    restful @ret
  end

  def new
    @host = Host.find(params[:host_id])
    @checks = Check.where(:host_id => @host.id)
    @metrics = @checks.inject([]){ |m, c| m += c.metrics }

    bootstrap @host, @checks, @metrics
  end

  def show
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
