
class InventoryController < ApplicationController

  def index
    @hosts = Host.all

    @bootstrap = [
      { :name => "hosts", :model => "HostList", :data => @hosts },
    ]

    respond_with(@hosts)
  end

  def show
    @host = Host.find(params[:id])
    respond_with(@host)
  end

end
