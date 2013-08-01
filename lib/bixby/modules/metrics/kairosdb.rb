
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
        parse_results(@client.get(opts))
      end

      def multi_get(opts=[])
        ret = @client.multi_get(opts)
        res = []
        ret.each do |r|
          res << parse_results(r)
        end

        return res
      end


      private

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
            :time => r.first,
            :val => r.last
          }
        }

        return data
      end

    end # self
  end # KairosDB

end # Metrics
end # Bixby
