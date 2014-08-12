
class Monitoring::HostsController < Monitoring::BaseController

  def index
    hosts = Host.for_user(current_user)
  end

  def show
    host = Host.find(_id)

    # by default, only load a subset of metrics
    keys = %w{ cpu.loadavg.5m cpu.usage.system cpu.usage.user mem.usage fs.disk.usage }
    metrics = Metric.metrics_for_host(host) do |m|
      !keys.include?(m.key)
    end

    bootstrap host
    bootstrap metrics, :type => Metric
  end

  def edit
  end

end
