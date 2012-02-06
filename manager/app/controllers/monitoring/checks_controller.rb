
class Monitoring::ChecksController < Monitoring::BaseController

  def create
    @host = Host.find(params[:host_id])
    @command = Command.find(params[:command][:id])
    
    # {"command"=>{"id"=>"1", "options"=>{"filesystem"=>"/"}}, "commit"=>"Create check", "host_id"=>"3"}
    opts = params[:command][:options]

    res = Resource.new
    res.host = @host
    res.name = opts.values.first
    res.save!

    check = Check.new
    check.resource = res 
    check.agent = @host.agent
    check.command = @command
    check.args = opts
    check.normal_interval = 60
    check.retry_interval = 60
    check.plot = true
    check.enabled = true
    check.save!

    redirect_to monitoring_host_path(@host)

  end

end
