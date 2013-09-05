
module PumaRunner
  class Base

    attr_accessor :config, :binder, :app, :events, :server

    def initialize
      self.events = Puma::Events.stdio # somewhere to send logs, at least
    end


    # Helpers

    # PID file path
    #
    # @return [String] pid file path
    def pid_file
      config.options[:pidfile]
    end

    # Make sure PID file dir exists
    def ensure_pid_dir
      pid_dir  = File.dirname(pid_file())
      if not File.directory? pid_dir then
        FileUtils.mkdir_p(pid_dir)
      end
    end

    # Read the current PID file
    #
    # @return [Fixnum] pid
    def read_pid
      if not File.exists? pid_file then
        return nil
      end
      pid = File.read(pid_file)
      if pid.nil? or pid.empty? then
        return nil
      end
      return pid.strip.to_i
    end

    # Load and validate configuration from PUMA_CONF
    #
    # @return [Puma::Configuration] config
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
    #
    # @return [Puma::Binder]
    def bind_sockets
      binds = config.options[:binds]
      events.log "* Binding to #{binds.inspect}"
      binder = Puma::Binder.new(events)
      binder.import_from_env # always try to import, if they are there
      binder.parse(binds, events) # not sure why we need events again

      binder
    end

    # Boot the Rails environment
    #
    # @return [Rack::Middleware]
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

    # Export the file descriptors into the ENV for use by child processes
    #
    # @return [Hash] FD redirect options for Kernel.exec
    def export_fds
      redirects = {:close_others => true}
      self.binder.listeners.each_with_index do |(bind,io),i|
        ENV["PUMA_INHERIT_#{i}"] = "#{io.to_i}:#{bind}"
        redirects[io.to_i] = io.to_i
      end
      redirects
    end

    # Spawn the child process in a subshell
    def respawn_child
      cmd = PUMA_SCRIPT + " start_child"
      redirects = export_fds()
      child_pids << fork { exec(cmd, redirects) }
      events.log "* started child process #{child_pids.last}"
    end

  end # Base
end # PumaRunner
