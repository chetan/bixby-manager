
class Monitoring::ChecksController < Monitoring::BaseController

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
