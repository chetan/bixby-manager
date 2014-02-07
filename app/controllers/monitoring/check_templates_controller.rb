
class Monitoring::CheckTemplatesController < Monitoring::BaseController

  def new
    # bootstrap tags, :name => "tags"
    bootstrap Command.for_monitoring(), :name => "commands", :model => "MonitoringCommandList"
  end

end
