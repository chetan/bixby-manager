
class Monitoring::HostsController < Monitoring::BaseController

  def index
    @hosts = Host.for_user(current_user)
  end

  def show

    # TODO error if no id
    @host = Host.find(params[:id])
    @checks = Check.where(:host_id => @host)
    @metrics = Metric.metrics_for_host(@host)

    bootstrap @host, @checks
    bootstrap @metrics, :type => Metric
  end

  def edit
  end

end
