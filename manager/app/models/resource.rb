
class Resource < ActiveRecord::Base

  belongs_to :host
  has_one :check
  has_one :command, :through => :check

  def metrics(time_start=nil, time_end=nil, tags = {}, agg = "sum", downsample = nil)
    self.class.metrics(self.check, time_start, time_end, tags, agg, downsample)
  end

  def self.metrics_for_host(host_id)
    resources = Resource.where(:host_id => host_id).to_api({ :inject =>
      proc { |obj, hash|
        hash[:metrics] = for_ui(obj.metrics(nil, nil, nil, nil, "1h-avg"))
      }
    }, false)

    # validate vals
    resources.each do |res|
      # make sure we have at least 2 values so we can graph them
      if res[:metrics].values.first[:vals].size == 1 then
        check_id = res[:metrics].values.first[:tags]["check_id"]
        res[:metrics] = for_ui(metrics(check_id)) # no downsampling
      end
    end

    return resources
  end


  private

  def self.for_ui(metrics)
    metrics.each do |k, met|
      met[:vals] = met[:vals].map { |v| { :x => v[:time], :y => v[:val] } }
    end
    return metrics
  end

  def self.metrics(check_id, time_start=nil, time_end=nil, tags = {}, agg = "sum", downsample = nil)
    time_start = Time.new - 86400 if time_start.nil?
    time_end = Time.new if time_end.nil?
    tags ||= {}
    agg ||= "sum"

    Metrics.new.get_for_check(check_id, time_start, time_end, tags, agg, downsample)
  end

end
