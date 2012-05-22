
class Monitoring::HostsController < Monitoring::BaseController

  def index
    @hosts = Host.all
  end

  def show

    # TODO error if no id
    @host = Host.find(params[:id])
    @checks = Check.where(:host_id => @host)
    @metrics = Metric.metrics_for_host(@host)

    @bootstrap = [
      { :name => "host", :model => "Host", :data => @host },
      { :name => "checks", :model => "CheckList", :data => @checks },
      { :name => "metrics", :model => "MetricList", :data => @metrics },
    ]
  end

  def edit
  end

end
