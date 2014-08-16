
class Inventory::HostsController < UiController

  def index
    query = params[:q] || params[:query]
    if not query.blank? then
      hosts = Host.search(query, current_user)
    else
      hosts = Host.for_user(current_user)
    end
    bootstrap hosts
  end

  def show
    host = Host.find(_id)
    bootstrap host
  end

end
