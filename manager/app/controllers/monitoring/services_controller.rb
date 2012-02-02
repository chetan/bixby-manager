
class Monitoring::ServicesController < Monitoring::BaseController

  def new
    @host = Host.find(params[:host_id])
    @commands = Command.where("command LIKE 'monitoring/%' OR command LIKE 'nagios/%'")

    if params[:command_id] then
      @command = Command.find(params[:command_id])
    end

  end

end
