
# put in teardown:
# Sidekiq.redis{ |r| r.flushdb }



# override to inject MockRedis
module Sidekiq
  class RedisConnection
    def self.build_client(options)
      ::Logging.logger[Bixby].debug "creating redis client"
      LogMockRedis.instance
    end
    private_class_method :build_client
  end
end

# no-op for RedisAPIChannel
class MockRedis
  def publish(key, data)
  end
end

# Wrapper around MockRedis to log every call
class LogMockRedis
  include Singleton
  def initialize
    @redis = MockRedis.new
  end
  def method_missing(sym, *args, &block)
    Logging.logger[Bixby].debug ":#{sym}, #{args.inspect}"
    @redis.send(sym, *args, &block)
  end
end
