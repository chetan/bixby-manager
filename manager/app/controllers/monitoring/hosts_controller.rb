
class Monitoring::HostsController < Monitoring::BaseController

  def index
    @hosts = Host.all
  end

  def show
    @host = Host.find(params[:id])
    # TODO error if no id
    @resources = Resource.where(:host_id => @host.id)

    @bootstrap = [
      { :name => "host", :model => "Host", :data => @host },
      { :name => "resources", :model => "ResourceList", :data => @resources },
    ]
  end

  def edit
  end

end
