
module PumaRunner
  class Base

    attr_accessor :config, :binder, :app, :events, :server, :pid
    attr_accessor :child_pids # probably don't need this

    def initialize
      @events     = Puma::Events.stdio # somewhere to send logs, at least
      @config     = load_config()
      @pid        = Pid.new(config.options[:pidfile])
      @child_pids = []

      @daemon_starter = DaemonStarter.new(pid.pid_dir, File.basename(pid.pid_file))
    end

    def log(str)
      events.log(str)
    end

    def error(str)
      events.error(str)
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
        error "Rails app not configured!"
        exit 1
      end

      config
    end

    # Attempt to bind to sockets
    #
    # @return [Puma::Binder]
    def bind_sockets
      binds = config.options[:binds]
      log "* Binding to #{binds.inspect}"
      binder = Puma::Binder.new(events)
      binder.import_from_env # always try to import, if they are there
      binder.parse(binds, events) # not sure why we need events again

      binder
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
      log "* started child process #{child_pids.last}"
    end

  end # Base
end # PumaRunner
