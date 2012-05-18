
class Monitoring::HostsController < Monitoring::BaseController

  def index
    @hosts = Host.all
  end

  def show
    @host = Host.find(params[:id])
    # TODO error if no id
    @metrics = Metric.metrics_for_host(@host.id)

    @bootstrap = [
      { :name => "host", :model => "Host", :data => @host },
      { :name => "resources", :model => "ResourceList", :data => @metrics },
    ]
  end

  def edit
  end

end
