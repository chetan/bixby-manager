
require 'bixby/modules/metrics/driver'

module Bixby
class Metrics

  class KairosDB < Driver
    class << self

      def configure(config)
        if config.include? :kairosdb then
          c = config[:kairosdb]
          @client = Continuum::KairosDB.new(c[:host], c[:telnet_port], c[:http_port])
        end
      end

      def put(key, value, timestamp, metadata = {})
        @client.metric(key.strip, value, timestamp, metadata)
      end

      def get(opts={})
        fix_timestamps(opts)
        parse_results(@client.get(opts))
      end

      def multi_get(opts=[])
        if opts.blank? then
          return opts
        end

        opts.each{ |opt| fix_timestamps(opt) }
        ret = @client.multi_get(opts)
        res = []
        ret.each do |r|
          res << parse_results(r)
        end

        return res
      end


      private

      # KairosDB requires timestamps to be in milliseconds
      def fix_timestamps(hash)
        return if hash.blank?
        hash[:start_time] = hash[:start_time].to_i * 1000
        hash[:end_time] = hash[:end_time].to_i * 1000
      end

      def parse_results(ret)

        if !ret or ret.empty? then
          return nil
        end

        tags = {}
        ret["tags"].each{ |k,v| tags[k] = v.first }

        data = []
        ret["values"].each{ |r|
          data << {
            :key => ret["name"],
            :tags => tags,
            :time => r.first/1000,
            :val => r.last
          }
        }

        return data
      end

    end # self
  end # KairosDB

end # Metrics
end # Bixby

Bixby::Metrics.driver = Bixby::Metrics::KairosDB
