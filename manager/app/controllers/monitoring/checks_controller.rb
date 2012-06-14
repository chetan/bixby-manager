
class Monitoring::ChecksController < Monitoring::BaseController

  # GET "/monitoring/hosts/3/checks" ?metric_id=56 (optional)
  def index
    @host = Host.find(params[:host_id])

    if params[:metric_id] then
      @ret = Metric.find(params[:metric_id].to_i).check
    else
      @ret = Check.where(:host_id => @host)
    end

    restful @ret.to_api
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

  def show

  end

  def create

    # Parameters: {"command_id"=>1, "host_id"=>"3", "args"=>{"mount"=>"/"}}

    host = Host.find(params[:host_id])
    command = Command.find(params[:command_id])
    opts = params[:args]

    check = Bixby::Monitoring.new.add_check(host, command, opts)
    restful check
  end

end
