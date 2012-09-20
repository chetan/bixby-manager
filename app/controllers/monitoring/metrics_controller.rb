
class Monitoring::MetricsController < Monitoring::BaseController

  # GET "/monitoring/hosts/3/metrics"
  def index
    @host = Host.find(params[:host_id])
    @metrics = Metric.metrics_for_host(@host)

    restful @metrics
  end

  def show
    metric = Metric.find(params[:id].to_i)
    metric.load_data!

    bootstrap metric, metric.check, metric.check.host
    restful metric
  end

end
