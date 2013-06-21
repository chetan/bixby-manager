
require 'bixby/modules/metrics/driver'

module Bixby
class Metrics

  class MongoDB < Driver

    ID_KEYS = %w{host_id check_id org_id tenant_id}.inject({}){ |m, k| m[k] = 1; m }.with_indifferent_access

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
          ap ID_KEYS
          opts[:tags].each do |k,v|
            tags["tags.#{k}"] = ID_KEYS.include?(k) ? v.to_i : v
          end
          ret = ret.and(tags)
        end

        # cheap hack to fix value type
        return ret.map{ |r|
          {
            :time => r[:time],
            :key => r[:key],
            :val => r[:val].to_f,
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
