
class Monitoring::MetricsController < Monitoring::BaseController

  def index
    host = Host.find(_id(:host_id))
    metrics = Metric.metrics_for_host(host)

    bootstrap host
    bootstrap host.checks, :type => Check
    bootstrap metrics, :type => Metric
  end

  def show
    metric = Metric.find(_id)

    downsample = params[:downsample]
    if downsample.blank? then
      # down't downsample when less than 12hrs of data avail
      downsample = (Time.new - metric.created_at < 43200) ? nil : "5m-avg"
    end

    metric.load_data!(params[:start], params[:end], {}, "sum", downsample)

    bootstrap metric, metric.check, metric.check.host
  end

end
