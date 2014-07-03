
class Monitoring::CheckTemplatesController < Monitoring::BaseController

  def new
    bootstrap Host.all_tags(current_user), :name => "tags", :model => "HostTag"
    bootstrap Command.for_monitoring(current_user), :name => "commands", :model => "MonitoringCommandList"
  end

  def show
    bootstrap CheckTemplate.find(_id)
  end

end
