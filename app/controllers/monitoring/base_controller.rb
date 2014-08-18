
class Monitoring::BaseController < UiController

  # /monitoring
  def index
    hosts = Host.for_user(current_user)
    checks = Check.where(:host_id => hosts)

    # def get_for_checks(checks, start_time, end_time, tags = {}, agg = "sum", downsample = nil, &block)
    keys = %w{ cpu.loadavg.5m cpu.usage.system cpu.usage.user mem.usage fs.disk.usage }
    metrics = Bixby::Metrics.new.get_for_checks(checks, Time.new-86400, Time.new, {}, "sum", "1h-avg") do |m|
      !keys.include?(m.key)
    end

    bootstrap hosts
    bootstrap metrics, :type => Metric



    return

    bootstrap CheckTemplate.where(:org_id => current_user.org_id).includes(:items => {:command => :repo}), :type => CheckTemplate

    oncalls = OnCall.where(:org_id => current_user.org_id)
    bootstrap oncalls, :type => OnCall

    users = User.where(:org_id => current_user.org_id)
    bootstrap users, :type => User

  end

end
