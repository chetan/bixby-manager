
module Rake::DSL

  # Disable logging before running the optional block.
  # If a block is passed, then logging will be re-enabled after it runs.
  def disable_logging

    logger = Logging.logger.root
    old_log_appenders = logger.appenders
    logger.clear_appenders

    # remove stdout appenders
    logger.add_appenders(old_log_appenders.reject{ |a| a.kind_of? Logging::Appenders::Stdout })

    return if not block_given?
    yield

    # reset
    logger.clear_appenders
    logger.add_appenders(old_log_appenders)

  end
  alias_method :disable_logging!, :disable_logging

end
