
class Monitoring::BaseController < UiController

  # /monitoring
  def index
    hosts = Host.for_user(current_user)
    checks = Check.where(:host_id => hosts)
    metrics = Bixby::Metrics.new.get_for_checks(checks, Time.new-86400, Time.new, {}, "sum", "1h-avg", &Metric.overview_filter)

    bootstrap hosts
    bootstrap metrics, :type => Metric
  end

end
