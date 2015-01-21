
# replace Sidekiq logger with our own
if Module.const_defined? :Sidekiq then

  Sidekiq::Logging.logger = Logging.logger[Sidekiq]

  if Rails.env == "development" && Sidekiq.server? then
    # quiet logs on stdout
    Logging.appenders["stdout"].level = :info
  end

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
