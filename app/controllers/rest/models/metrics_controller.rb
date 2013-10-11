
class Rest::Models::MetricsController < ::Rest::ApiController

  # GET "/rest/hosts/3/metrics"
  def index
    @host = Host.find(params[:host_id])
    @metrics = Metric.metrics_for_host(@host)

    restful @metrics
  end

  # GET "/rest/hosts/:host_id/metrics/:id"
  def show
    metric = Metric.find(_id)
    downsample = params[:downsample] || "5m-avg"
    metric.load_data!(_id(:start, true), _id(:end, true), {}, "sum", downsample)

    restful metric
  end

end
