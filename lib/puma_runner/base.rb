
module PumaRunner
  class Base

    attr_accessor :config, :binder, :app, :events, :server

    def initialize
      self.events = Puma::Events.stdio # somewhere to send logs, at least
    end

    # Load and validate configuration from PUMA_CONF
    def load_config
      # defaults from Puma::CLI
      options = {
        :min_threads => 0,
        :max_threads => 16,
        :quiet       => false,
        :debug       => false,
        :binds       => [],
        :workers     => 0,
        :daemon      => false,
        :worker_boot => []
      }
      options[:config_file] = PUMA_CONF

      config = Puma::Configuration.new(options)
      config.load

      if not config.app_configured? then
        events.error "! Rails app not configured"
        exit 1
      end

      config
    end

    # Attempt to bind to sockets
    def bind_sockets
      binds = config.options[:binds]
      events.log "* Binding to #{binds.inspect}"
      binder = Puma::Binder.new(events)
      binder.import_from_env # always try to import, if they are there
      binder.parse(binds, events) # not sure why we need events again

      binder
    end

    # Boot the Rails environment
    def boot_rails
      events.log "* Booting rails app"
      begin
        return config.app
      rescue Exception => e
        events.error "! Unable to load rails app"
        puts e
        puts e.backtrace
        exit 1
      end
    end

    # Setup daemon signals
    def setup_signals

      Signal.trap("QUIT") do
        events.log "* Shutting down on QUIT signal"
        # server.stop(true)
      end

      Signal.trap("USR2") do
        events.log "* Graceful restart on USR2 signal"
        # server.begin_restart
      end

    end

  end # Base
end # PumaRunner
