
class Monitoring::MetricsController < Monitoring::BaseController

  # GET "/monitoring/hosts/3/metrics"
  def index
    @host = Host.find(params[:host_id])
    @metrics = Metric.metrics_for_host(@host)

    respond_to do |format|
      format.html
      format.json { render :json => @metrics }
    end
  end

  def show

    metric = Metric.find(params[:id].to_i)
    metric.load_data!

    @bootstrap = [
      { :name => "host", :model => "Host", :data => @host },
      { :name => "check", :model => "Check", :data => metric.check.to_api },
      { :name => "metric", :model => "Metric", :data => metric.to_api },
    ]

    respond_to do |format|
      format.html
      format.json { render :json => metric.to_api }
    end
  end

end
