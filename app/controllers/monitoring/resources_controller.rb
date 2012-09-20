
class Monitoring::ResourcesController < Monitoring::BaseController


  def index
    @host = Host.find(params[:host_id])
    @resources = Resource.metrics_for_host(@host.id)

    restful @resources
  end

end
