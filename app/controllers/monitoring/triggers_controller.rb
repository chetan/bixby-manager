
class Monitoring::TriggersController < Monitoring::BaseController

  def new
    host = Host.find(params[:host_id])
    checks = Check.where(:host_id => host.id)
    metrics = checks.inject([]){ |m, c| m += c.metrics }

    bootstrap host, checks, metrics
  end

end
