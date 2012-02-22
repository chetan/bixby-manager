
class Metrics < API

  class << self

    attr_accessor :driver

    def configure(config)
      driver.configure(config)
    end

  end

  def driver
    self.class.driver()
  end

  def put(key, value, timestamp = Time.new, metadata = {})
    driver.put(key, value, timestamp, metadata)
  end

  # Store the results of one or more Checks
  #
  # @param [Hash] results
  # @option results [FixNum] :check_id
  # @option results [String] :key base key name
  # @option results [String] :status OK, WARNING, CRITICAL, UNKNOWN, TIMEOUT
  # @option results [FixNum] :timestamp
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
        metadata[:host] = check.agent.host.hostname if metadata[:host] or metadata["host"]
        metadata[:host_id] = check.agent.host.id
        metadata[:org_id] = check.agent.host.org.id
        metadata[:tenant_id] = check.agent.host.org.tenant.id

        time = Time.at(result["timestamp"])
        base = result["key"] ? result["key"]+"." : ""
        metric["metrics"].each do |k,v|
          put("#{base}#{k}", v, time, metadata)
        end

      end

      nil
    end

  end

end

require 'modules/metrics/driver'
require 'modules/metrics/opentsdb' if Metrics.driver.nil?
