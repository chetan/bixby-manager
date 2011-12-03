
class InventoryController < ApplicationController

  def index
    @hosts = Host.all
  end

end
