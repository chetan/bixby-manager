
class Monitoring::CheckTemplatesController < Monitoring::BaseController

  def index
    bootstrap CheckTemplate.where(:org_id => current_user.org_id).includes(:items => {:command => :repo}), :type => CheckTemplate
  end

  def new
    bootstrap Host.all_tags(current_user), :name => "tags", :model => "HostTag"
    bootstrap Command.for_monitoring(current_user), :name => "commands", :model => "MonitoringCommandList"
  end

  def show
    bootstrap CheckTemplate.find(_id)
  end

end
