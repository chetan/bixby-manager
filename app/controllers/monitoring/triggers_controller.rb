
class Monitoring::TriggersController < Monitoring::BaseController

  def new
    host = Host.find(_id(:host_id))
    checks = Check.where(:host_id => host.id).includes(:host, :metric_infos, :command => :repo, :metrics => :tags)
    metrics = checks.inject([]){ |m, c| m += c.metrics }

    bootstrap host, checks, metrics

    if params[:for_check] && params[:for_metric] then
      bootstrap Check.find(params[:for_check].to_i), :type => Check, :name => "for_check"
      bootstrap Metric.find(params[:for_metric].to_i), :type => Metric, :name => "for_metric"
    end
  end

end
