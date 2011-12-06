
class Monitoring::BaseController < ApplicationController

  before_filter :set_current_tab

  def set_current_tab
    @current_tab = "Monitoring"
  end

end
