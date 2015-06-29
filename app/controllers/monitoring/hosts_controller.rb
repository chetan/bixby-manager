
class Monitoring::HostsController < Monitoring::BaseController

  def index
    hosts = Host.for_user(current_user)
  end

  def show
    # by default, only load a subset of metrics
    host = Host.find(_id)
    metrics = Metric.metrics_for_host(host, &Metric.overview_filter)

    bootstrap host
    bootstrap metrics, :type => Metric
  end

  def edit
  end

end
