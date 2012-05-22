
class Monitoring::ChecksController < Monitoring::BaseController

  # GET "/monitoring/hosts/3/checks"
  def index
    @host = Host.find(params[:host_id])
    @checks = Check.where(:host_id => @host)

    respond_to do |format|
      format.html
      format.json { render :json => @checks.to_api }
    end
  end

  def show

  end

  def create

    # Parameters: {"command_id"=>1, "host_id"=>"3", "args"=>{"mount"=>"/"}}

    host = Host.find(params[:host_id])
    command = Command.find(params[:command_id])
    opts = params[:args]

    check = Monitoring.new.add_check(host, command, opts)

    respond_to do |format|
      format.json { render :json => check }
    end
  end

end
