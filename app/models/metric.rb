
class Metric < ActiveRecord::Base

  METADATA_SOURCE = 2

  belongs_to :check
  has_and_belongs_to_many :tags, :class_name => :Metadata, :join_table => "metrics_metadata"

  attr_accessor :data, :metadata

  # Find an existing Metric or return a new instance
  #
  # @param [Check] check
  # @param [String] key
  # @param [Hash] metadata
  # @return [Metric]
  def self.for(check, key, metadata = {})

    hash = hash_metadata(metadata)
    m = Metric.first(:conditions => {:check_id => check.id, :key => key, :tag_hash => hash})
    if not m.blank? then
      return m
    end

    m = Metric.new
    m.check = check
    m.key = key
    m.tag_hash = hash
    m.tags = []
    m.tags += metadata.map { |k,v| Metadata.for(k, v, METADATA_SOURCE) } if metadata

    return m
  end

  def self.metrics_for_host(host, time_start=nil, time_end=nil, tags = {}, agg = "sum", downsample = nil)

    # set defaults
    time_start = Time.new - 86400 if time_start.nil?
    time_end = Time.new if time_end.nil?
    tags ||= {}
    agg ||= "sum"
    downsample ||= "1h-avg"

    metrics = Bixby::Metrics.new.get_for_host(host, time_start, time_end, tags, agg, downsample)

    # validate vals
    metrics.each do |res|
      # make sure we have at least 2 values so we can graph them
      if res.data and res.data.size < 2 then
        # run metrics query again w/o downsampling values this time
        check_id = res["check_id"]
        check = Check.find(check_id.to_i)
        res.data = metrics(check, time_start, time_end, tags, agg).data
      end
    end

    return metrics
  end

  def metrics(time_start=nil, time_end=nil, tags = {}, agg = "sum", downsample = nil)

    time_start = Time.new - 86400 if time_start.nil?
    time_end = Time.new if time_end.nil?
    tags ||= {}
    agg ||= "sum"

    tags[:check_id] = self.check.id
    self.tags.each{ |t| tags[t.key] = t.value }

    Bixby::Metrics.new.get_for_keys(self.key, time_start, time_end, tags, agg, downsample)
  end

  def load_data!(time_start=nil, time_end=nil, tags = {}, agg = "sum", downsample = nil)
    metrics = self.metrics(time_start, time_end, tags, agg, downsample).first
    self.data = metrics[:vals]
    self.metadata = metrics[:tags]
  end


  def self.for_ui(data)
    if data.blank? then
      data
    else
      data.map { |d| { :x => d[:time], :y => d[:val] } }
    end
  end

  def self.metrics(check_id, time_start=nil, time_end=nil, tags = {}, agg = "sum", downsample = nil)
    time_start = Time.new - 86400 if time_start.nil?
    time_end = Time.new if time_end.nil?
    tags ||= {}
    agg ||= "sum"

    Bixby::Metrics.new.get_for_check(check_id, time_start, time_end, tags, agg, downsample)
  end



  private


  def self.hash_metadata(metadata)
    key = []
    metadata.keys.each { |k| key << k << metadata[k] }
    return Digest::MD5.new.hexdigest(key.join("_"))
  end

end
