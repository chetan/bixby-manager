
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

  # Get metrics for the given options
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
    driver.get(opts)
  end

  # Retrieve multiple metrics simultaneously
  #
  # @param [Array<Hash>] reqs   An array of requests
  # @return [Array<Array>]
  #
  # @see #get
  def multi_get(reqs=[])
    driver.multi_get(reqs)
  end

  # Get the metrics for the given Check
  #
  # @param [Check] check
  # @param [Time] start_time
  # @param [Time] end_time
  # @param [Hash] tags        Tags to filter by, only check-related filters by default
  # @param [String] agg
  def get_for_check(check, start_time, end_time, tags = {}, agg = "sum", downsample = nil)

    if [Fixnum, String].include? check.class
      check = Check.find(check.to_i)
    end

    # foo = Metrics.new.get("hardware.cpu.loadavg.1m", Time.new-(86400*14), Time.new)
    # TODO add in other relevant keys like org, tenant
    tags[:check_id]    = check.id
    tags[:resource_id] = check.resource.id
    tags[:host_id]     = check.resource.host.id
    # tags[:org_id]    = @org_id
    # tags[:tenant_id] = @tenant_id

    return Rails.cache.fetch("metrics_for_check_#{check.id}", :expires_in => 2.minutes) do
      collect_metrics(check.metrics, start_time, end_time, tags, agg, downsample)
    end
  end

  # Get the metrics for the given Command
  #
  # @param [Command] command
  # @param [Time] start_time
  # @param [Time] end_time
  # @param [Hash] tags        Tags to filter by, only check-related filters by default
  # @param [String] agg
  def get_for_command(command, start_time, end_time, tags = {}, agg = "sum", downsample = nil)

    if [Fixnum, String].include? command.class
      command = Command.find(command.to_i)
    end

    # TODO add in other relevant keys like org, tenant
    # tags[:org_id]    = @org_id
    # tags[:tenant_id] = @tenant_id

    return Rails.cache.fetch("metrics_for_command_#{command.id}", :expires_in => 2.minutes) do
      collect_metrics(CommandMetric.for(command), start_time, end_time, tags, agg, downsample)
    end
  end

  # Get the metrics for the given keys
  def get_for_keys(keys, start_time, end_time, tags = {}, agg = "sum", downsample = nil)

    # TODO add in other relevant keys like org, tenant
    # tags[:org_id]    = @org_id
    # tags[:tenant_id] = @tenant_id

    return collect_metrics(keys, start_time, end_time, tags, agg, downsample)
  end

  # Store the given metric
  #
  # @param [String] key       Metric key name
  # @param [Fixnum] value     Value, can be either integer or decimal
  # @param [Time] timestamp   Time at which value was recorded
  # @param [Hash] metadata    Additional tags to record
  def put(key, value, timestamp = Time.new, metadata = {})
    driver.put(key, value, timestamp, metadata)
  end

  # Store the results of one or more Checks
  #
  # @param [Hash] results
  # @option results [Fixnum] :check_id
  # @option results [String] :key base key name
  # @option results [String] :status OK, WARNING, CRITICAL, UNKNOWN, TIMEOUT
  # @option results [Fixnum] :timestamp
  # @option results [Hash] :metrics key/value pairs of metrics
  # @option results [Array<String>] :errors list of errors, if any
  #
  # @return [void]
  def put_check_result(results)

    if not results.kind_of? Array then
      results = [ results ]
    end

    results.each do |result|

      check = Check.find(result["check_id"].to_i)

      result["metrics"].each do |metric|

        metadata = metric["metadata"] || {}
        if not (metadata[:host] or metadata["host"]) then
          metadata[:host] = check.agent.host.hostname || check.agent.host.ip
        end
        metadata[:host_id]     = check.agent.host.id
        metadata[:check_id]    = check.id
        metadata[:resource_id] = check.resource.id
        metadata[:org_id]      = check.agent.host.org.id
        metadata[:tenant_id]   = check.agent.host.org.tenant.id

        time = Time.at(result["timestamp"])
        base = result["key"] ? result["key"]+"." : ""
        metric["metrics"].each do |k,v|
          put("#{base}#{k}", v, time, metadata)
        end

      end

      nil
    end

  end


  private

  # Fetch a list of metrics by metric name
  #
  # @param [Object] command_metrics   Array of metric Strings or CommandMetric objects
  def collect_metrics(command_metrics, start_time, end_time, tags, agg, downsample)

    if command_metrics.first.kind_of? CommandMetric then
      command_metrics = command_metrics.map{ |m| m.metric }
    end

    reqs = []
    command_metrics.each do |m|
      # tags should all be the same, so factor them out
      reqs << { :key => m, :start_time => start_time, :end_time => end_time, :tags => tags, :agg => agg, :downsample => downsample }
    end

    results = multi_get(reqs)

    metrics = {}
    command_metrics.each_with_index do |m, i|
      vals = results[i]
      next if not vals or vals.empty?

      ret = { :key => m, :tags => vals.first[:tags] }
      ret[:vals] = vals.map{ |v| { :time => v[:time], :val => v[:val] } }
      metrics[m] = ret
    end

    return metrics
  end

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
