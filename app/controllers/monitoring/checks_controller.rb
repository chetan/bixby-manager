
class Monitoring::ChecksController < Monitoring::BaseController

  def show
    host = Host.find(_id(:host))
    check = Check.find(_id).includes(:command)
    downsample = params[:downsample] || "1h-avg"
    metrics = Metric.metrics_for_check(check, nil, nil, {}, "sum", downsample)

    bootstrap host, check
    bootstrap metrics, :name => "metrics"
  end

  def new
    bootstrap Host.find(params[:host_id]), Host.for_user(current_user)
    bootstrap Command.for_monitoring(current_user), :name => "commands", :model => "MonitoringCommandList"

    if params[:command_id] then
      command = Command.find(params[:command_id])
      bootstrap command, :name => "command", :model => "MonitoringCommand"
    end

  end

end
