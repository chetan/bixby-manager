
# replace Sidekiq logger with our own
if Module.const_defined? :Sidekiq and Sidekiq.server? then
  Sidekiq::Logging.logger = Logging.logger[Sidekiq]

  module Sidekiq
    module Logging
      def self.with_context(msg)
        begin
          ::Logging.mdc["sidekiq"] = msg
          yield
        ensure
          ::Logging.mdc["sidekiq"] = nil
        end
      end
    end
  end

end
