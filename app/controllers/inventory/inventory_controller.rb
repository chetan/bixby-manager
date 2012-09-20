
class InventoryController < ApplicationController

  def index
    @hosts = Host.all
    bootstrap @hosts
    restful @hosts
  end

  def show
    @host = Host.find(params[:id])
    restful @host
  end

end
