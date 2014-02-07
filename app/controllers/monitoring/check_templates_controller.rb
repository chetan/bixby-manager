
class Monitoring::CheckTemplatesController < Monitoring::BaseController

  def new
    bootstrap Host.all_tags(current_user), :name => "tags", :model => "HostTag"
    bootstrap Command.for_monitoring(), :name => "commands", :model => "MonitoringCommandList"
  end

end
