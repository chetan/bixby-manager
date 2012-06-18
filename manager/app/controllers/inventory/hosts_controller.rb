
class HostsController < ApplicationController

  def index
    @hosts = Host.all
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

end
