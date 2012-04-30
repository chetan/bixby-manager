
class Monitoring::ResourcesController < Monitoring::BaseController

  def new
    @host = Host.find(params[:host_id])
    @commands = Command.where("command LIKE 'monitoring/%' OR command LIKE 'nagios/%'")

    if params[:command_id] then
      @command = Command.find(params[:command_id])
    end

  end

  def index
    @host = Host.find(params[:host_id])
    @resources = Resource.metrics_for_host(@host.id)

    respond_to do |format|
      format.html
      format.json { render :json => @resources }
    end
  end

end
