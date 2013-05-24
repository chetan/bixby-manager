
class Monitoring::MetricsController < Monitoring::BaseController

  def show
    metric = Metric.find(_id)
    downsample = params[:downsample] || "5m-avg"
    metric.load_data!(params[:start], params[:end], {}, "sum", downsample)

    bootstrap metric, metric.check, metric.check.host
  end

end
