
class Inventory::HostsController < UiController

  def index
    query = params[:q] || params[:query]
    include_inactive = (params[:inactive] && params[:inactive] == "true")

    if not query.blank? then
      hosts = Host.search(query, current_user)
    else
      hosts = Host.for_user(current_user)
    end

    bootstrap hosts
  end

  def show
    bootstrap Host.find(_id), :use => Bixby::ApiView::HostWithMetadata
  end

end
