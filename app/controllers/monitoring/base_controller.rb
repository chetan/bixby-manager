
class Monitoring::BaseController < UiController

  # /monitoring
  def index
    hosts = Host.for_user(current_user)
    checks = Check.where(:host_id => hosts)
    keys = %w{ cpu.loadavg.5m cpu.usage.system cpu.usage.user mem.usage fs.disk.usage }
    metrics = Bixby::Metrics.new.get_for_checks(checks, Time.new-86400, Time.new, {}, "sum", "1h-avg") do |m|
      !keys.include?(m.key)
    end

    bootstrap hosts
    bootstrap metrics, :type => Metric
  end

end
