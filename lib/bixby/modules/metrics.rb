
module Bixby
class Metrics < API

  class << self

    attr_accessor :driver

    # Configure the active driver
    #
    # @param [Hash] config
    def configure(config)
      driver.configure(config)
    end

  end

  # Fetch the active driver
  #
  # @return [Bixby::Metrics::Driver] driver instance
  def driver
    self.class.driver()
  end

  # Get metrics matching the given options
  #
  # @param [Hash] opts
  # @option opts [String] :key          Metric key name
  # @option opts [Time] :start_time     Accepts either Time object or Fixnum (epoch in sec)
  # @option opts [Time] :end_time       Accepts either Time object or Fixnum (epoch in sec)
  # @option opts [Hash] :tags           Additional tags to filter by
  # @option opts [String] :agg          Aggregate function; one of: sum, max, min, avg (default="sum")
  # @option opts [String] :downsample   Whether or not to downsample values (default=nil)
  #
  # @example
  #   Downsample is a combination of a time period and an aggregation function.
  #   It takes the following form: "time-agg", where
  #     time = 1s, 1m, 1h, 1d
  #     agg = min, max, sum, avg
  #   ex: 10m-avg
  #
  # @return [Array<Hash>] Array of metrics
  def get(opts={})
    process_results(driver.get(opts)).first
  end

  # Retrieve multiple metrics simultaneously
  #
  # @param [Array<Hash>] reqs   An array of requests
  # @return [Array<Array>]
  #
  # @see #get
  def multi_get(reqs=[])
    process_results(driver.multi_get(reqs))
  end

  # Get the metrics for the given Host
  #
  # @param [Host] host
  # @param [Time] start_time
  # @param [Time] end_time
  # @param [Hash] tags        Tags to filter by, only check-related filters by default
  # @param [String] agg
  def get_for_host(host, start_time, end_time, tags = {}, agg = "sum", downsample = nil)

    host = get_model(host, Host)

    # TODO add in other relevant keys like org, tenant
    tags[:host_id]     = host.id
    # tags[:org_id]    = @org_id
    # tags[:tenant_id] = @tenant_id

    get_for_checks(Check.where(:host_id => host.id), start_time, end_time, tags, agg, downsample)
  end

  # Get the metrics for the given Check
  #
  # @param [Check] check
  # @param [Time] start_time
  # @param [Time] end_time
  # @param [Hash] tags        Tags to filter by, only check-related filters by default
  # @param [String] agg
  def get_for_check(check, start_time, end_time, tags = {}, agg = "sum", downsample = nil)

    check = get_model(check, Check)

    # foo = Metrics.new.get("hardware.cpu.loadavg.1m", Time.new-(86400*14), Time.new)
    # TODO add in other relevant keys like org, tenant
    tags[:check_id]    = check.id
    tags[:host_id]     = check.host.id
    # tags[:org_id]    = @org_id
    # tags[:tenant_id] = @tenant_id

    return Rails.cache.fetch("metrics_for_check_#{check.id}", :expires_in => 2.minutes) do
      get_for_checks(check, start_time, end_time, tags, agg, downsample).first
    end
  end

  # Get the metrics for the given keys
  def get_for_keys(keys, start_time, end_time, tags = {}, agg = "sum", downsample = nil)

    keys = array(keys)

    # TODO add in other relevant keys like org, tenant
    # tags[:org_id]    = @org_id
    # tags[:tenant_id] = @tenant_id

    if keys.first.kind_of? MetricInfo then
      keys = keys.map{ |m| m.metric }
    end

    reqs = []
    keys.each do |m|
      # tags should all be the same, so factor them out
      reqs << { :key => m, :start_time => start_time, :end_time => end_time, :tags => tags, :agg => agg, :downsample => downsample }
    end

    return multi_get(reqs)
  end

  # Store the given metric
  #
  # @param [String] key       Metric key name
  # @param [Fixnum] value     Value, can be either integer or decimal
  # @param [Time] timestamp   Time at which value was recorded (default: current time)
  # @param [Hash] metadata    Additional tags to record (default: none)
  def put(key, value, timestamp = Time.new, metadata = {})
    driver.put(key, value, timestamp, metadata)
  end

  # Store the results of one or more Checks. Each result may contain multiple metrics.
  #
  # @param [Hash] results
  # @option results [Fixnum] :check_id
  # @option results [String] :key             base key name
  # @option results [String] :status          OK, WARNING, CRITICAL, UNKNOWN, TIMEOUT
  # @option results [Fixnum] :timestamp
  # @option results [Hash] :metrics           key/value pairs of metrics and metadata
  # @option results [Array<String>] :errors   list of errors, if any
  #
  # @return [void]
  def put_check_result(results)

    results = array(results)

    ActiveRecord::Base.transaction do
      results.each do |result|

        # TODO [security] validate check ownership
        check = Check.find(result["check_id"].to_i)

        result["metrics"].each do |metric|

          base = result["key"] ? result["key"]+"." : ""

          # find/save incoming metrics using passed in metadata
          metadata = metric["metadata"] || {}
          metric["metrics"].each do |k,v|
            key = "#{base}#{k}"
            m = Metric.for(check, key, metadata)
            m.last_value = v
            m.touch
            m.save!
          end

          # attach extra metadata before storing
          if not (metadata[:host] or metadata["host"]) then
            metadata[:host] = check.agent.host.hostname || check.agent.host.ip
          end
          metadata[:host_id]     = check.host.id
          metadata[:check_id]    = check.id
          metadata[:org_id]      = check.agent.host.org.id
          metadata[:tenant_id]   = check.agent.host.org.tenant.id

          # save
          time = result["timestamp"].to_i
          metric["metrics"].each do |k,v|
            key = "#{base}#{k}"
            put(key, v, time, metadata)
          end

        end

        true
      end # results.each
    end # transaction

  end


  private

  # Get Metrics for the given checks
  def get_for_checks(checks, start_time, end_time, tags = {}, agg = "sum", downsample = nil)
    metrics = Metric.includes(:check).where(:check_id => checks).includes(:tags)
    keys = metrics.map { |m| m.key }

    reqs = []
    metrics.each do |metric|
      all_tags = {}
      if metric.tags then
        metric.tags.each{ |t| all_tags[t.key] = t.value }
      end
      all_tags.merge!(tags)
      reqs << { :key => metric.key, :start_time => start_time, :end_time => end_time, :tags => all_tags, :agg => agg, :downsample => downsample }
    end

    responses = multi_get(reqs)

    responses.each_with_index do |data, i|
      if not data.empty? then
        metrics[i].data     = data[:vals]
        metrics[i].metadata = data[:tags]
      end
    end

    return metrics.map { |m| m }
  end

  # Process raw results
  #
  # @param [Array<Array>] array of metric responses from the driver
  def process_results(results)

    if results.blank? then
      return results
    end

    if not results.first.kind_of? Array then
      results = [ results ]
    end

    metrics = []
    results.each do |met|
      if not met or met.empty? then
        metrics << met
        next
      end

      ret = { :key => met.first[:key], :tags => met.first[:tags] }
      ret[:vals] = met.map{ |v| { :time => v[:time], :val => v[:val] } }
      metrics << ret
    end

    return metrics
  end

  # currently unused method
  def create_cache_key(opts)
    key = []
    [:key, :start_time, :end_time, :agg, :downsample].each { |k| key << opts[k] }
    opts[:tags].keys.sort{ |k| key << k << opts[:tags][k] }
    return key.join("_")
  end

end # Metrics
end # Bixby

require 'bixby/modules/metrics/rescan'
require 'bixby/modules/metrics/driver'
require 'bixby/modules/metrics/opentsdb' if Bixby::Metrics.driver.nil?
