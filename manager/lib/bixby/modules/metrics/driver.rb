
class Metrics

  class Driver

    class << self

      def configure(config)
        raise NotImplementedError.new("configure must be overridden!")
      end

      def put(key, value, timestamp, metadata = {})
        raise NotImplementedError.new("put must be overridden!")
      end

      # Retrieve metrics for a given key
      #
      # @param [Hash] opts
      # @option opts [String] :key
      # @option opts [Time] :start_time  Accepts either Time object or Fixnum (epoch in sec)
      # @option opts [Time] :end_time    Accepts either Time object or Fixnum (epoch in sec)
      # @option opts [Hash] :tags  Additional tags to filter by
      # @option opts [String] :agg  Aggregate function; one of: sum, max, min, avg (default="sum")
      # @option opts [String] :downsample  Whether or not to downsample values (default=nil)
      def get(opts={})
        raise NotImplementedError.new("get must be overridden!")
      end

      # Execute multiple get requests
      #
      # @param [Array<Hash>] opts  same hash params as get()
      def multi_get(opts=[])
        raise NotImplementedError.new("multi_get must be overridden!")
      end

    end

  end

end
