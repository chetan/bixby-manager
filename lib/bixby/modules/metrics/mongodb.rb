
require 'bixby/modules/metrics/driver'

module Bixby
class Metrics

  class MongoDB < Driver

    class MetricData
      include ::Mongoid::Document
      field :time, :type => DateTime
      field :key, :type => String
      field :val, :type => BigDecimal
    end

    class << self

      def configure(config)
        Mongoid.logger = Logging.logger[:Mongoid]
        Moped.logger   = Logging.logger[:Moped]
      end

      def put(key, value, timestamp, metadata = {})
        data = {:key => key, :val => value, :time => timestamp, :tags => metadata}
        MetricData.create!(data)
      end

      def get(opts={})
        ret = MetricData.where(:key => opts[:key]).
          and(:time.gte => opts[:start_time]).
          and(:time.lte => opts[:end_time])

        if not opts[:tags].blank? then
          tags = {}
          opts[:tags].each do |k,v|
            tags["tags.#{k}"] = v
          end
          ret = ret.and(tags)
        end

        # cheap hack to fix value type
        return ret.map{ |r|
          {
            :time => r[:time],
            :key => r[:key],
            :val => BigDecimal.new(r[:val]),
            :tags => r[:tags]
          }
        }
      end

      def multi_get(opts=[])
        # cheap hack for now
        ret = opts.map{ |opt| get(opt) }
      end

    end # self
  end # MongoDB

end # Metrics
end # Bixby

Bixby::Metrics.driver = Bixby::Metrics::MongoDB
