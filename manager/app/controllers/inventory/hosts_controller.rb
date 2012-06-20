
class Inventory::HostsController < ApplicationController

  def index
    @hosts = Host.all
    bootstrap @hosts
    restful @hosts
  end

  def show
    @host = Host.find(params[:id])
    bootstrap @host
    restful @host
  end

end
