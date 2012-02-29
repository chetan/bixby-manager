
class InventoryController < ApplicationController

  def index
    @hosts = Host.all

    respond_to do |format|
      format.html
      format.json { render :json => @hosts }
    end
  end

  def show
    @host = Host.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render :json => @host }
    end
  end

end
