
class Rest::Models::MetricsController < ::Rest::BaseController

  # List all metrics for the host
  # GET "/rest/hosts/3/metrics"
  def index
    host = Host.find(_id(:host_id))
    metrics = Metric.metrics_for_host(host)

    restful metrics
  end

  # List all metrics for the check
  def index_for_check
    downsample = params[:downsample] || "1h-avg"
    restful Metric.metrics_for_check(_id(:check_id), _id(:start, true), _id(:end, true), {}, "sum", downsample)
  end

  # GET "/rest/hosts/:host_id/metrics/:id"
  def show
    metric = Metric.find(_id)
    downsample = params[:downsample] || "5m-avg"
    metric.load_data!(_id(:start, true), _id(:end, true), {}, "sum", downsample)

    restful metric
  end

  # GET host summary metrics
  def summary

    if params[:host_id]
      # pull summary metrics for this host
      host = Host.find(_id(:host_id))
      metrics = Metric.metrics_for_host(host) do |m|
        !Metric::OVERVIEW.include?(m.key)
      end

    else
      # pull summary metrics for all hosts
      hosts = Host.for_user(current_user)
      checks = Check.where(:host_id => hosts)
      metrics = Bixby::Metrics.new.get_for_checks(checks, Time.new-86400, Time.new, {}, "sum", "1h-avg") do |m|
        !Metric::OVERVIEW.include?(m.key)
      end
    end

    restful metrics
  end

end
