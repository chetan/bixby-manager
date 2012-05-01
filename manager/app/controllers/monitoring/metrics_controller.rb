
class Monitoring::MetricsController < Monitoring::BaseController

  def show

    resource = Resource.find(params[:id].to_i)
    check = resource.check

    tags = {}
    tags[:check_id]    = check.id
    tags[:resource_id] = check.resource.id
    tags[:host_id]     = check.resource.host.id

    @metrics = Metrics.new.get_for_keys([ params[:metric] ], params[:start].to_i, params[:end].to_i)
    # TODO find a better place to do this
    @metrics.each do |k, met|
      met[:vals] = met[:vals].map { |v| { :x => v[:time], :y => v[:val] } }
    end

    respond_to do |format|
      format.html
      format.json { render :json => @metrics }
    end
  end

end
