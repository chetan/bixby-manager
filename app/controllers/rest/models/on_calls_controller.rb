
class Rest::Models::OnCallsController < UiController

  def index
    @oncalls = OnCall.where(:org_id => current_user.org_id)
    restful @oncalls
  end

  def show
    @host = Host.find(params[:id])
    restful @host
  end

  def update
    @host = Host.find(params[:id])
    attrs = pick(:alias, :desc)
    attrs[:tag_list] = params[:tags]
    @host.update_attributes(attrs)

    restful @host
  end

  def destroy
    @host = Host.find(params[:id])
    @host.destroy
    @host.agent.destroy if @host.agent

    restful @host
  end

  def update_facts
    @host = Host.find(params[:id])
    Bixby::Inventory.new.update_facts(@host)
    restful @host
  end

end
