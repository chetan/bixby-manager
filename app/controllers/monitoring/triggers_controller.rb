
class Monitoring::TriggersController < Monitoring::BaseController

  # GET "/monitoring/hosts/3/triggers"
  # def index
  #   @host = Host.find(params[:host_id])

  #   if params[:metric_id] then
  #     @ret = Metric.find(params[:metric_id].to_i).check
  #   else
  #     @ret = Check.where(:host_id => @host)
  #   end

  #   restful @ret
  # end

  def new
    @host = Host.find(params[:host_id])
    @checks = Check.where(:host_id => @host.id)
    @metrics = @checks.inject([]){ |m, c| m += c.metrics }

    bootstrap @host, @checks, @metrics
  end

  def show
  end

  def create

    # Parameters:
    # {
    #   "host_id"   => "1",
    #   "metric"    => "hardware.cpu.loadavg.1m",
    #   "severity"  => "warning",
    #   "sign"      => "ge",
    #   "threshold" => "5",
    #   "status"    => ["WARNING", "UNKNOWN", "TIMEOUT"],
    # }

    options = pick(:host_id, :check_id, :metric_id, :severity, :sign, :threshold, :status)
    trigger = Bixby::Monitoring.new.add_trigger(options)

    restful trigger
  end

end
