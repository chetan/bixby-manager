
class Metrics < API

  class RescanPlugin
    def self.update_command(cmd)

      spec = cmd.to_command_spec
      config = spec.load_config()
      base = config["key"]

      # create a hash with only the metric name (remove base)
      existing = {}
      metrics = CommandMetric.where("command_id = ?", cmd.id)
      metrics.each do |m|
        k = m.metric.gsub(/#{base}\./, '')
        existing[k] = m
      end

      # create/update metrics
      new_metrics = config["metrics"]
      new_metrics.each do |key, metric|
        cm = existing.include?(key) ? existing[key] : CommandMetric.new
        if not cm.command_id then
          cm.command_id = cmd.id
          cm.metric = base + "." + key
        end
        cm.unit = metric["unit"]
        cm.desc = metric["desc"]
        cm.save!

        Rails.logger.info "* updated metric: #{cm.metric}"
      end

    end
  end

  class << self

    attr_accessor :driver

    def configure(config)
      driver.configure(config)
    end

  end

  def driver
    self.class.driver()
  end

  # downsample format:
  # time-agg
  # time = 1s, 1m, 1h, 1d
  # agg = min, max, sum, avg
  # ex: 10m-avg
  def get(key, start_time, end_time, tags = {}, agg = "sum", downsample = nil)
    driver.get(key, start_time, end_time, tags, agg, downsample)
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

    return collect_metrics(check.metrics, start_time, end_time, tags, agg, downsample)
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

    return collect_metrics(CommandMetric.for(command), start_time, end_time, tags, agg, downsample)
  end

  # Get the metrics for the given keys
  def get_for_keys(keys, start_time, end_time, tags = {}, agg = "sum", downsample = nil)

    # TODO add in other relevant keys like org, tenant
    # tags[:org_id]    = @org_id
    # tags[:tenant_id] = @tenant_id

    return collect_metrics(keys, start_time, end_time, tags, agg, downsample)
  end


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

    metrics = {}
    command_metrics.each do |m|
      # tags should all be the same, so factor them out
      vals = get(m, start_time, end_time, tags, agg, downsample)
      next if not vals or vals.empty?
      ret = { :key => m, :tags => vals.first[:tags] }
      ret[:vals] = vals.map{ |v| { :time => v[:time], :val => v[:val] } }
      metrics[m] = ret
    end

    return metrics
  end

end

require 'modules/metrics/driver'
require 'modules/metrics/opentsdb' if Metrics.driver.nil?
