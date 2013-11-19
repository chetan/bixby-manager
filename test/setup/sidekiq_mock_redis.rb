
# put in teardown:
# Sidekiq.redis{ |r| r.flushdb }



# override to inject MockRedis
module Sidekiq
  class RedisConnection
    def self.build_client(options)
      MockRedis.new
    end
    private_class_method :build_client
  end
end

# no-op for RedisAPIChannel
class MockRedis
  def publish(key, data)
  end
end
