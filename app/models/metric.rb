# == Schema Information
#
# Table name: metrics
#
#  id          :integer          not null, primary key
#  check_id    :integer          not null
#  name        :string(255)
#  key         :string(255)      not null
#  tag_hash    :string(32)       not null
#  status      :integer
#  last_value  :decimal(20, 2)
#  last_status :integer
#  created_at  :datetime         not null
#  updated_at  :datetime
#


class Metric < ActiveRecord::Base

  if not const_defined? :METADATA_SOURCE then
    METADATA_SOURCE = 2

    module Status
      UNKNOWN  = 0
      OK       = 1
      WARNING  = 2
      CRITICAL = 3
      TIMEOUT  = 4
    end

    Bixby::Util.create_const_map(Status)
  end

  belongs_to :check
  has_and_belongs_to_many :tags, :class_name => :Metadata, :join_table => "metrics_metadata"

  multi_tenant :via => :check

  attr_accessor :data, :metadata, :query

  # Shortcut accessor for this Metric's Org
  #
  # @return [Org]
  def org
    self.check.org
  end

  # Find an existing Metric or return a new instance
  #
  # @param [Check] check
  # @param [String] key
  # @param [Hash] metadata
  # @return [Metric]
  def self.for(check, key, metadata = {})

    hash = hash_metadata(metadata)
    m = Metric.where(:check_id => check.id, :key => key, :tag_hash => hash).first
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
        res.query[:downsample] = nil
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
    self.query = { :start => time_start, :end => time_end, :tags => tags, :downsample => downsample }
  end

  def self.metrics(check_id, time_start=nil, time_end=nil, tags = {}, agg = "sum", downsample = nil)
    time_start = Time.new - 86400 if time_start.nil?
    time_end = Time.new if time_end.nil?
    tags ||= {}
    agg ||= "sum"

    Bixby::Metrics.new.get_for_check(check_id, time_start, time_end, tags, agg, downsample)
  end

  def ok?
    self.status == Status::OK
  end
  alias_method :normal?, :ok?

  def warning?
    self.status == Status::WARNING
  end

  def critical?
    self.status == Status::CRITICAL
  end

  def unknown?
    self.status == Status::UNKNOWN
  end

  def timeout?
    self.status == Status::TIMEOUT
  end

  private


  def self.hash_metadata(metadata)
    key = []
    metadata.keys.each { |k| key << k << metadata[k] }
    return Digest::MD5.new.hexdigest(key.join("_"))
  end

end
