
class Inventory::HostsController < UiController

  def index
    query = params[:q] || params[:query]
    if not query.blank? then
      @hosts = Host.search(query)
    else
      @hosts = Host.all
    end
    bootstrap @hosts
    restful @hosts
  end

  def show
    @host = Host.find(params[:id])
    bootstrap @host
    restful @host
  end

end
