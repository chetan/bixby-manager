
class Monitoring::ServicesController < Monitoring::BaseController

  def new
    @host = Host.find(params[:host_id])

  end

end
