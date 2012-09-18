
class HostsController < ApplicationController

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

end
