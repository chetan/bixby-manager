
require 'modules/metrics/driver'

class Metrics

  class OpenTSDB < Metrics::Driver

    class << self

      def configure(config)
        if config.include? :opentsdb then
          c = config[:opentsdb]
          @client = Continuum::Client.new(c[:host], c[:port])
        end
      end

      def put(key, value, timestamp, metadata = {})
        @client.metric(key.strip, value, timestamp, metadata)
      end

    end

  end

end

Metrics.driver = Metrics::OpenTSDB
