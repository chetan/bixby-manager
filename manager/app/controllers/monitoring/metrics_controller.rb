
class Monitoring::MetricsController < Monitoring::BaseController

  def show
    @metrics = Resource.find(params[:id]).metrics(nil, nil, nil, nil, "1h-avg")

    # rename time/val to x/y for graphing
    @metrics.each do |k, met|
      met[:vals] = met[:vals].map { |v| { :x => v[:time], :y => v[:val] } }
    end

    respond_to do |format|
      format.html
      format.json { render :json => @metrics }
    end
  end

end
