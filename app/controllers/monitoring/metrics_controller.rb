
class Monitoring::MetricsController < Monitoring::BaseController

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
