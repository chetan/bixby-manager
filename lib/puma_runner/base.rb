
module PumaRunner
  class Base

    attr_accessor :config, :binder, :app, :events, :server, :pid

    def initialize
      @events     = Puma::Events.new($stdout, $stderr)
      @config     = load_config()
      @pid        = Pid.new(config.options[:pidfile])

      @daemon_starter = DaemonStarter.new(pid.pid_dir, File.basename(pid.pid_file))

      # always change to configured app dir
      # don't expand path because we don't want to resolve any symlinks
      Dir.chdir(@config.options[:directory])
    end

    def log(str)
      events.log(str)
    end

    def error(str)
      events.error(str)
    end

    def debug(str)
      events.debug(str)
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
        :worker_boot => [],

        # custom defaults (differ from Puma)
        :redirect_append => true,
        :config_file     => PUMA_CONF
      }

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
      debug "* Binding to #{binds.inspect}"

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
      if not self.binder then
        return redirects
      end
      self.binder.listeners.each_with_index do |(bind,io),i|
        ENV["PUMA_INHERIT_#{i}"] = "#{io.to_i}:#{bind}"
        redirects[io.to_i] = io.to_i
      end
      redirects
    end

    # Spawn the child process in a subshell
    def respawn_child
      cmd = PUMA_SCRIPT + " server"
      redirects = export_fds()
      child_pid = fork { exec(cmd, redirects) }

      log "* started server process #{child_pid}"
    end

  end # Base
end # PumaRunner
