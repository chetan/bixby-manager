
class Rest::Models::HostsController < ::Rest::ApiController

  def index
    query = params[:q] || params[:query]
    if not query.blank? then
      hosts = Host.search(query, current_user)
    else
      hosts = Host.for_user(current_user)
    end
    restful hosts
  end

  def show
    restful Host.find(_id)
  end

  def update
    host = Host.find(_id)
    attrs = pick(:alias, :desc)
    attrs[:tag_list] = params[:tags]
    host.update_attributes(attrs)

    restful host
  end

  def destroy
    host = Host.find(_id)
    host.destroy
    host.agent.destroy if host.agent

    restful host
  end

  def update_facts
    host = Host.find(_id)
    Bixby::Inventory.new.update_facts(host)
    restful host
  end

  def tags
    restful Host.all_tags(current_user)
  end

end
