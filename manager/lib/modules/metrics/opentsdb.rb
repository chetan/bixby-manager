
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

      def get(key, start_time, end_time, tags = {}, agg = "sum", downsample = nil)

        # create opts hash

        # rate of change needed??
        m = "#{agg}"
        m += ":" + downsample if not downsample.blank?
        m += ":#{key}"
        if tags and not tags.empty? then
          m += "{" + tags.to_a.map{ |a| "#{a[0]}=#{a[1]}" }.join(",") + "}"
        end
        m = URI.escape(m)
        start_time = Time.at(start_time) if start_time.kind_of? Fixnum
        end_time = Time.at(end_time) if end_time.kind_of? Fixnum
        opts = {
          :m => m,
          :start => start_time,
          :end => end_time,
          :format => :ascii
        }

        res = []
        ret = @client.query(opts)
        return res if ret.nil? or ret.empty?

        # parse results
        # hardware.cpu.loadavg.1m 1330108266 0.3799999952316284 org_id=1 host_id=3 host=127.0.0.1 tenant_id=1
        ret.split(/\n/).each do |line|
          s = line.split(/ /)
          key = s.shift
          time = s.shift.to_i
          val = s.shift.to_f
          tags = {}
          s.each{ |a| b = a.split(/\=/); tags[b[0]] = (b[0] =~ /_id$/) ? b[1].to_i : b[1] }
          res << { :key => key, :time => time, :val => val, :tags => tags }
        end
        return res
      end

    end

  end

end

Metrics.driver = Metrics::OpenTSDB
