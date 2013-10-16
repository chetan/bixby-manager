
class Rest::Models::MetricsController < ::Rest::ApiController

  # List all metrics for the host
  # GET "/rest/hosts/3/metrics"
  def index
    @host = Host.find(params[:host_id])
    @metrics = Metric.metrics_for_host(@host)

    restful @metrics
  end

  # List all metrics for the check
  def index_for_check
    restful Check.find(params[:check_id]).metrics
  end

  # GET "/rest/hosts/:host_id/metrics/:id"
  def show
    metric = Metric.find(_id)
    downsample = params[:downsample] || "5m-avg"
    metric.load_data!(_id(:start, true), _id(:end, true), {}, "sum", downsample)

    restful metric
  end

end
