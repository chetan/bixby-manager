
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
end

# Use a custom logger for the Bixby::* namespace when in TEST env
if ::Rails.env == "test" then

  # A simple subclass of the Stdout appender which writes to whatever
  # $stdout is currently pointing to
  module Logging::Appenders
    class StdoutTest < Stdout
      def canonical_write( str )
        return self if @io.nil?
        str = str.force_encoding(encoding) if encoding and str.encoding != encoding
        $stdout.syswrite str
        self
      rescue StandardError => err
        self.level = :off
        ::Logging.log_internal {"appender #{name.inspect} has been disabled"}
        ::Logging.log_internal(-2) {err}
      end
    end
  end

  Logging::Appenders::StdoutTest.new( 'stdout_test',
    :auto_flushing => true,
    :layout => Logging.layouts.pattern(
      :pattern => '%.1l, [%d] %5l -- %c: %m\n',
      :color_scheme => 'bright'
    )
  )

end
