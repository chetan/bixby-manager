
class Monitoring::MetricsController < Monitoring::BaseController

  def show

    metric = Metric.find(params[:id].to_i)
    metric.load_data!

    respond_to do |format|
      format.html
      format.json { render :json => metric.to_api }
    end
  end

end
