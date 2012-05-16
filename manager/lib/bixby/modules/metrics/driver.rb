
module Bixby
class Metrics

  class Driver

    class << self

      def configure(config)
        raise NotImplementedError.new("configure must be overridden!")
      end

      def put(key, value, timestamp, metadata = {})
        raise NotImplementedError.new("put must be overridden!")
      end

      # Get metrics for the given options
      #
      # @param [Hash] opts
      # @option opts [String] :key          Metric key name
      # @option opts [Time] :start_time     Accepts either Time object or Fixnum (epoch in sec)
      # @option opts [Time] :end_time       Accepts either Time object or Fixnum (epoch in sec)
      # @option opts [Hash] :tags           Additional tags to filter by
      # @option opts [String] :agg          Aggregate function; one of: sum, max, min, avg (default="sum")
      # @option opts [String] :downsample   Whether or not to downsample values (default=nil)
      #
      # @example
      #   Downsample is a combination of a time period and an aggregation function.
      #   It takes the following form: "time-agg", where
      #     time = 1s, 1m, 1h, 1d
      #     agg = min, max, sum, avg
      #   ex: 10m-avg
      #
      # @return [Array<Hash>] Array of metrics
      def get(opts={})
        raise NotImplementedError.new("get must be overridden!")
      end

      # Execute multiple get requests
      #
      # @param [Array<Hash>] opts  An array of requests
      #
      # @see #get
      def multi_get(opts=[])
        raise NotImplementedError.new("multi_get must be overridden!")
      end

    end

  end

end # Metrics
end # Bixby
