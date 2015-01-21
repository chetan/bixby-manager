
# lower to info (always)
::Rails.cache.logger.level = :info

# make sure all previously created loggers have tracing enabled
Logging::Repository.instance.children(:root).each{ |l| l.trace = true }

if ::Rails.env == "development" then
  class Logging::Logger
    def formatter
      return ActiveSupport::Logger::SimpleFormatter.new
    end
  end

  # ActiveSupport::Dependencies.log_activity = true

  # EM::Hiredis.logger = Logging.logger[EM::Hiredis]
  # EM::Hiredis.logger.level = :debug
end
