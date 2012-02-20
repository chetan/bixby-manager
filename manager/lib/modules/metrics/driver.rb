
class Metrics

  class Driver

    class << self

      def configure(config)
        raise NotImplementedError.new("configure must be overridden!")
      end

      def put(key, value, timestamp, metadata = {})
        raise NotImplementedError.new("put must be overridden!")
      end

    end

  end

end
