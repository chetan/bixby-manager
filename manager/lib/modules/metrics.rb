
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

end

require 'modules/metrics/driver'
require 'modules/metrics/opentsdb' if Metrics.driver.nil?
