
require 'bixby/modules/metrics/driver'

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

      def get(opts={})
        opts = create_opts(opts)
        ret = @client.query(opts)
        return parse_results(ret)
      end

      def multi_get(opts=[])
        reqs = []
        opts.each do |opt|
          reqs << create_opts(opt)
        end

        ret = @client.multi_query(reqs)
        res = []
        ret.each do |r|
          res << parse_results(r)
        end

        return res
      end


      private

      def parse_results(ret)
        # hardware.cpu.loadavg.1m 1330108266 0.3799999952316284 org_id=1 host_id=3 host=127.0.0.1 tenant_id=1
        res = []
        return [] if ret.nil? or ret.empty?
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


      def create_opts(opts={})
        # create opts hash
        opts = HashWithIndifferentAccess.new(opts)

        # rate of change needed??
        agg = opts[:agg] || "sum"
        m = "#{agg}"
        m += ":" + opts[:downsample] if not opts[:downsample].blank?
        m += ":#{opts[:key]}"

        tags = opts[:tags] || {}
        if tags and not tags.empty? then
          m += "{" + tags.to_a.map{ |a| "#{a[0]}=#{a[1]}" }.join(",") + "}"
        end

        m = URI.escape(m)

        start_time = opts[:start_time]
        end_time = opts[:end_time]
        start_time = Time.at(start_time.to_i) if [Fixnum, String].include? start_time.class
        end_time = Time.at(end_time.to_i) if [Fixnum, String].include? end_time.class

        return {
          :m => m,
          :start => start_time,
          :end => end_time,
          :format => :ascii
        }
      end

    end # self
  end # OpenTSDB
end # Metrics

Metrics.driver = Metrics::OpenTSDB
