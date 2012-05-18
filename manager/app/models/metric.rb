
class Metric < ActiveRecord::Base

  belongs_to :check

  # Find an existing Metric or return a new instance
  #
  # @param [Check] check
  # @param [String] key
  # @param [Hash] metadata
  # @return [Metric]
  def self.for(check, key, metadata)

    hash = hash_metadata(metadata)
    m = Metric.first(:conditions => {:check_id => check.id, :key => key, :tag_hash => hash})
    if not m.blank? then
      return m
    end

    m = Metric.new
    m.check = check
    m.key = key
    m.tag_hash = hash

    return m

  end

  def self.metrics_for_host(host_id)
    resources = Metric.where(:check_id => Check.where(:host_id => host_id.to_i)).to_api({ :inject =>
      proc { |obj, hash|
        hash[:data] = for_ui(obj.metrics(nil, nil, nil, nil, "1h-avg"))
        add_metric_info(obj.check, hash)
      }
    }, false)

    # validate vals
    resources.each do |res|
      # make sure we have at least 2 values so we can graph them
      if res[:data].values.first[:vals].size == 1 then
        check_id = res[:data].values.first[:tags]["check_id"]
        check = Check.find(check_id.to_i)
        res[:data] = for_ui(metrics(check)) # no downsampling
        add_metric_info(check, res)
      end
    end

    return resources
  end

  def metrics(time_start=nil, time_end=nil, tags = {}, agg = "sum", downsample = nil)
    self.class.metrics(self.check, time_start, time_end, tags, agg, downsample)
  end


  private

  def self.hash_metadata(metadata)
    key = []
    metadata.keys.each { |k| key << k << metadata[k] }
    return Digest::MD5.new.hexdigest(key.join("_"))
  end

  def self.add_metric_info(check, hash)
    arr = MetricInfo.for(check.command)
    arr.each { |a|
      hash[:data][a.metric]["desc"] = a.desc
      hash[:data][a.metric]["unit"] = a.unit
    }
  end

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

    Bixby::Metrics.new.get_for_check(check_id, time_start, time_end, tags, agg, downsample)
  end

end
