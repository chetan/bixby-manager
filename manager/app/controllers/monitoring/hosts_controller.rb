
class Monitoring::HostsController < Monitoring::BaseController

  def index
    @hosts = Host.all
  end

  def show
    @host = Host.find(params[:id])
    # TODO error if no id
    @resources = Resource.where(:host_id => @host.id).to_api({ :inject =>
      proc { |obj, hash|
        metrics = obj.metrics(nil, nil, nil, nil, "1h-avg")
        # rename time/val to x/y for graphing
        metrics.each do |k, met|
          met[:vals] = met[:vals].map { |v| { :x => v[:time], :y => v[:val] } }
        end
        hash[:metrics] = metrics
      }
    })

    @bootstrap = [
      { :name => "host", :model => "Host", :data => @host },
      { :name => "resources", :model => "ResourceList", :data => @resources },
    ]
  end

  def edit
  end

end
