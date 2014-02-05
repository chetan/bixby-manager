
class Monitoring::ChecksController < Monitoring::BaseController

  def show
    host = Host.find(_id)
    check = Check.find(_id)
    downsample = params[:downsample] || "1h-avg"
    metrics = Metric.metrics_for_check(check, nil, nil, {}, "sum", downsample)

    bootstrap host, check
    bootstrap metrics, :name => "metrics"
  end

  def new
    @host = Host.find(params[:host_id])
    @commands = Command.where("command LIKE 'monitoring/%' OR command LIKE 'nagios/%'")

    bootstrap @host
    @bootstrap << { :name => "commands", :model => "MonitoringCommandList", :data => to_api(@commands) }

    if params[:command_id] then
      @command = Command.find(params[:command_id])
      @bootstrap << { :name => "command", :model => "MonitoringCommand", :data => to_api(@command) }
    end

  end

end
