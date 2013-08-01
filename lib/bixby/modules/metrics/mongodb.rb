
require 'bixby/modules/metrics/driver'

module Bixby
class Metrics

  class MongoDB < Driver

    ID_KEYS = %w{host_id check_id org_id tenant_id}.inject({}){ |m, k| m[k] = 1; m }.with_indifferent_access

    class MetricData
      include ::Mongoid::Document
      include ::Mongoid::Attributes::Dynamic
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

        start_time = opts[:start_time]
        end_time = opts[:end_time]
        start_time = Time.at(start_time.to_i) if [Fixnum, String].include? start_time.class
        end_time = Time.at(end_time.to_i) if [Fixnum, String].include? end_time.class

        ret = MetricData.where(:key => opts[:key]).
          and(:time.gte => start_time).
          and(:time.lte => end_time)

        if not opts[:tags].blank? then
          tags = {}
          opts[:tags].each do |k,v|
            tags["tags.#{k}"] = ID_KEYS.include?(k) ? v.to_i : v
          end
          ret = ret.and(tags)
        end

        # cheap hack to fix value type
        return ret.map{ |r|
          {
            :key => r[:key],
            :tags => r[:tags],
            :time => r[:time],
            :val => r[:val].to_f
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
