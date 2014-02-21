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

  module Status
    UNKNOWN  = 0
    OK       = 1
    WARNING  = 2
    CRITICAL = 3
    TIMEOUT  = 4
  end
  Bixby::Util.create_const_map(Status)

  belongs_to :check
  has_many :tags, -> { where("object_type = #{Metadata::Type::METRIC}") }, :class_name => :Metadata, :foreign_key => :object_fk_id

  multi_tenant :via => :check

  attr_accessor :data, :metadata, :query

  # Shortcut accessor for this Metric's Org
  #
  # @return [Org]
  def org
    self.check.org
  end

  # Add new tag to this metric
  #
  # @param [String] key
  # @param [String] value
  # @param [Fixnum] source           (optional, default: METRIC)
  def add_tag(key, value, source=Metadata::Source::METRIC)
    tags << Metadata.new(:key => key, :value => value, :source => source,
                             :object_type => Metadata::Type::METRIC, :object_fk_id => id)
    nil
  end

  # Find an existing Metric or return a new instance
  #
  # @param [Check] check
  # @param [String] key
  # @param [Hash] metadata          key/value pairs
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
    metadata.each{ |k,v| m.add_tag(k, v) } if metadata

    return m
  end

  # Retrieve metrics for the given check
  def self.metrics_for_check(check_id, time_start=nil, time_end=nil, tags = {}, agg = "sum", downsample = nil)
    time_start = Time.new - 86400 if time_start.nil?
    time_end = Time.new if time_end.nil?
    tags ||= {}
    agg ||= "sum"

    Bixby::Metrics.new.get_for_check(check_id, time_start, time_end, tags, agg, downsample)
  end

  # Retrieve metrics for the given host
  def self.metrics_for_host(host, time_start=nil, time_end=nil, tags = {}, agg = "sum", downsample = nil)

    # set defaults
    time_start = Time.new - 86400 if time_start.nil?
    time_end = Time.new if time_end.nil?
    tags ||= {}
    agg ||= "sum"
    downsample ||= "1h-avg"

    metrics = Bixby::Metrics.new.get_for_host(host, time_start, time_end, tags, agg, downsample)

    # remove metrics which don't have enough/any data
    # metrics.reject!{ |m| !m.updated_at.nil? && m.updated_at < 2.weeks.ago }

    # validate vals
    metrics.each do |metric|
      # make sure we have at least 2 values so we can graph them
      if metric.data and metric.data.size < 2 then
        # run metrics query again w/o downsampling values this time
        # data saved back in metric object
        Bixby::Metrics.new.get_for_metric(metric, time_start, time_end, tags, agg, nil)
        metric.query[:downsample] = nil
      end
    end

    return metrics
  end

  # Load the metric data associated with this Metric instance (using @key)
  def metrics(time_start=nil, time_end=nil, tags = {}, agg = "sum", downsample = nil)

    time_start = Time.new - 86400 if time_start.nil?
    time_end = Time.new if time_end.nil?
    tags ||= {}
    agg ||= "sum"

    tags[:check_id] = self.check.id
    self.tags.each{ |t| tags[t.key] = t.value }

    Bixby::Metrics.new.get_for_keys(self.key, time_start, time_end, tags, agg, downsample)
  end

  # Load data for this metric
  def load_data!(time_start=nil, time_end=nil, tags = {}, agg = "sum", downsample = nil)
    metrics = self.metrics(time_start, time_end, tags, agg, downsample).first
    if metrics then
      self.data     = metrics[:vals]
      self.metadata = metrics[:tags]
    end
    self.query = { :start => time_start, :end => time_end, :tags => tags, :downsample => downsample }
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
    parts = []
    metadata.keys.sort.each { |k| parts << k << metadata[k] }
    return Digest::MD5.new.hexdigest(parts.join("_"))
  end

end
