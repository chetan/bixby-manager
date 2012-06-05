
class HostsController < ApplicationController

  def index
    @hosts = Host.all
    bootstrap @hosts
    ap @hosts
    respond_with(@hosts)
  end

  def show
    @host = Host.find(params[:id])
    respond_with(@host)
  end

  def update
    @host = Host.find(params[:id])
    @host.update_attributes pick(:alias, :desc)
    @host.save!
    respond_with(@host)
  end

end
