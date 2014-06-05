
module Bixby

# Metrics collection and retrieval APIs
#
# Offered hooks:
#
#   * #put\_check\_results
#
class Metrics < API

  extend Bixby::Hooks

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
    begin
      return process_results(driver.get(opts)).first
    rescue Exception => ex
      # TODO re-raise
      log.error("failed to get metrics: #{ex.message}")
      log.error(ex)
      return []
    end
  end

  # Retrieve multiple metrics simultaneously
  #
  # @param [Array<Hash>] reqs   An array of requests
  # @return [Array<Array>]
  #
  # @see #get
  def multi_get(reqs=[])
    log.debug { "fetching metrics: " }
    log.debug { reqs }

    begin
      return process_results(driver.multi_get(reqs))
    rescue Exception => ex
      # TODO re-raise
      log.error("failed to get metrics: #{ex.message}")
      log.error(ex)
      return []
    end
  end

  # Get the metrics for the given Host
  #
  # @param [Host] host
  # @param [Time] start_time
  # @param [Time] end_time
  # @param [Hash] tags        Tags to filter by, only check-related filters by default
  # @param [String] agg
  # @param [String] downsample   Whether or not to downsample values (default=nil)
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
  # @param [String] downsample   Whether or not to downsample values (default=nil)
  def get_for_check(check, start_time, end_time, tags = {}, agg = "sum", downsample = nil)

    check = get_model(check, Check)

    # foo = Metrics.new.get("hardware.cpu.loadavg.1m", Time.new-(86400*14), Time.new)
    # TODO add in other relevant keys like org, tenant
    tags[:check_id]    = check.id
    tags[:host_id]     = check.host.id
    # tags[:org_id]    = @org_id
    # tags[:tenant_id] = @tenant_id

    get_for_checks(check, start_time, end_time, tags, agg, downsample)
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
  # Fires the :put_check_result hook on completion, passing results as the only param.
  #
  # @param [Array<Hash>] results              An array of results from one or more checks
  # @option results [Fixnum] :check_id
  # @option results [String] :key             base key name
  # @option results [String] :status          OK, WARNING, CRITICAL, UNKNOWN, TIMEOUT
  # @option results [Fixnum] :timestamp
  # @option results [Array]  :metrics
  #   * [Hash] :metrics                       key/value pairs
  #   * [Hash] :metadata                      key/value pairs
  # @option results [Array<String>] :errors   list of errors, if any
  #
  # @return [void]
  #
  # Example input:
  # ```ruby
  #    {
  #      "status"    => "OK",
  #      "timestamp" => 1329775841,
  #      "key"       => "hardware.storage.disk",
  #      "check_id"  => "77",
  #      "metrics" => [
  #        {
  #          "metrics"  => { "size"=>297, "used"=>202, "free"=>94, "usage"=>69 },
  #          "metadata" => { "mount"=>"/", "type"=>"hfs" }
  #        }
  #      ],
  #      "errors"=>[]
  #    }
  # ```
  #
  def put_check_result(results)

    results = array(results)
    metrics = []

    ActiveRecord::Base.transaction do
      results.each do |result|

        # skip if not reporting any metrics
        next if result["metrics"].blank?

        # TODO [security] validate check ownership
        check = Check.find(result["check_id"].to_i)
        time = Time.at(result["timestamp"].to_i)
        status = Metric::Status.lookup(result["status"]).to_i

        result["metrics"].each do |metric|

          base = result["key"] ? result["key"]+"." : ""

          # find/save incoming metrics using passed in metadata

          # note: we dup incoming metadata because modifying the original
          #       will break job retries in sidekiq
          #
          #       we also stringify all keys/vals because mongo, for instance,
          #       will store the given type while at the same time we *always*
          #       store only string values in the db.
          metadata = {}
          if metric["metadata"] then
            metric["metadata"].dup.each do |k,v|
              metadata[k.to_s] = v.to_s
            end
          end

          # attach extra metadata before storing
          metadata[:host_id]     = check.host.id
          metadata[:check_id]    = check.id
          metadata[:org_id]      = check.org.id
          metadata[:tenant_id]   = check.tenant.id

          # update last_value for all metrics
          metric["metrics"].each do |k,v|
            key = "#{base}#{k}"
            m = Metric.for(check, key, metadata)
            m.last_value  = v
            m.last_status = status
            m.updated_at  = time
            m.save!
            metrics << m
          end

          # save each metric
          metric["metrics"].each do |k,v|
            key = "#{base}#{k}"
            put(key, v, time, metadata)
          end

        end

        true
      end # results.each
    end # transaction

    self.class.run_hook(:put_check_result, metrics)
    nil
  end
  Bixby.set_async(Bixby::Metrics, :put_check_result)

  # Create a new annotation
  #
  # @param [String] name              name of event
  # @param [Array<String>] tags       list of tags (default: none)
  # @param [Time] timestamp           timestamp of event (defaut: now)
  # @param [String] detail            extra detail for event
  def add_annotation(name, tags=[], timestamp=Time.new, detail=nil)

    # find a suitable org_id to use
    org_id = @current_user ? @current_user.org.id : MultiTenant.current_tenant.orgs.first.id

    a = Annotation.new(:name => name, :tag_list => tags.join(","),
                       :created_at => timestamp, :detail => detail,
                       :org_id => org_id)
    a.save!
  end


  # Load data for a single Metric
  #
  # @param [Metric] metric
  # @param [Time] start_time
  # @param [Time] end_time
  # @param [Hash] tags        Tags to filter by, only check-related filters by default
  # @param [String] agg
  # @param [String] downsample   Whether or not to downsample values (default=nil)
  #
  # @return [Metric] metric
  def get_for_metric(metric, start_time, end_time, tags = {}, agg = "sum", downsample = nil)
    req = create_query(metric, start_time, end_time, tags, agg, downsample)
    data = get(req)

    metric.data     = data[:vals]
    metric.metadata = data[:tags]

    return metric
  end


  private

  # Get Metrics for the given checks
  def get_for_checks(checks, start_time, end_time, tags = {}, agg = "sum", downsample = nil)
    metrics = Metric.includes(:check).where(:check_id => checks).references(:checks).includes(:tags)

    reqs = metrics.map do |metric|
      create_query(metric, start_time, end_time, tags, agg, downsample)
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
  # @param [Array<Array>] results     array of metric responses from the driver
  def process_results(results)

    if results.blank? then
      return results || []
    end

    if not results.first.kind_of? Array then
      results = [ results ]
    end

    metrics = []
    results.each do |met|
      if not met or met.empty? then
        metrics << {} # just return an empty hash instead of whatever we got
        next
      end

      ret = { :key => met.first[:key], :tags => met.first[:tags] }
      ret[:vals] = met.map{ |v| { :time => v[:time], :val => v[:val] } }
      metrics << ret
    end

    return metrics
  end

  # Create a query for the given metric
  def create_query(metric, start_time, end_time, tags, agg, downsample)
    all_tags = {}
    if metric.tags then
      metric.tags.each{ |t| all_tags[t.key] = t.value }
    end
    all_tags.merge!(tags)
    if Time.new - metric.created_at < 3600 then
      downsample = nil
    end
    metric.query = { :start => start_time, :end => end_time, :tags => tags, :downsample => downsample }
    downsample = (Time.new - metric.created_at < 43200) ? "5m-avg" : downsample # show 5m-avg if less than 12 hours old

    return {
      :key        => metric.key,
      :start_time => start_time,
      :end_time   => end_time,
      :tags       => all_tags,
      :agg        => agg,
      :downsample => downsample
    }
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
