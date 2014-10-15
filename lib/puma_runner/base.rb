
require "mixlib/shellout"

module PumaRunner
  class Base

    attr_accessor :config, :binder, :app, :events, :server, :pid

    def initialize
      @events     = Puma::Events.new($stdout, $stderr)
      @config     = load_config()
      @pid        = Pid.new(config.options[:pidfile])

      @daemon_starter = DaemonStarter.new(pid.pid_dir, File.basename(pid.pid_file))
    end

    def rails_root
      @config.options[:directory]
    end

    def rails_env
      @config.options[:environment]
    end

    def log(str)
      events.log(ts(str))
    end

    def error(str)
      log("ERROR: #{str}")
      exit 1
    end

    def debug(str)
      events.debug(ts(str))
    end

    def ts(str)
      t = Time.new.to_s
      if str.nil? or str.empty? then
        return "[#{t}]"
      end
      str.split(/\n/).map{ |s| "[#{t}] #{s}" }.join("\n")
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
        :config_file     => File.join("config", "deploy", "puma.conf.rb")
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

      binder = PumaRunner::SocketBinder.new(events)
      binder.import_from_env    # always try to import, if they are there
      binder.import_from_socket
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

    def respawn_child
      respawn_child_exec()
      # respawn_child_fork()
    end

    def respawn_child_exec
      @socket_passer = SocketPasser.new(self.binder)
      @socket_passer.start

      runner = File.join(rails_root, "script", "puma")
      child_pid = rvm_exec("#{runner} server")
      Process.detach(child_pid)

      log "* started server process #{child_pid}, waiting for it to initialize..."

      @socket_passer.join

      log "* done"
      return child_pid
    end

    # Execute a command using rvm_wrapper.sh
    #
    # Wipes all traces of the currently running ruby version in favor of the version configured
    # in bixby.yml. This is to allow restarting across ruby versions
    #
    # @param [String] cmd
    #
    # @return [Fixnum] child PID
    def rvm_exec(cmd)
      conf = YAML.load_file(File.join(rails_root, "config", "bixby.yml"))[rails_env]
      env = {
        "USE_RUBY_VERSION"   => conf["ruby"],
        "USE_RVM"            => conf["rvm"],
        "_ORIGINAL_GEM_PATH" => nil,
        "BUNDLE_BIN_PATH"    => nil,
        "RUBYOPT"            => nil,
        "RUBYLIB"            => nil,
        "PATH"               => ENV["PATH"].split(/:/).reject{ |s| s =~ %r{\.rvm|/usr/local/rvm} }.join(":"),
        "RUN_IN_BG"          => "1"
      }

      rvm_wrapper = File.join(rails_root, "config", "deploy", "rvm_wrapper.sh")
      cmd = Mixlib::ShellOut.new("#{rvm_wrapper} #{cmd}", :environment => env)
      cmd.run_command

      s = cmd.stdout.strip
      if s.to_i.to_s == s then
        return s.to_i # the real pid is returned from the script, assuming it ran successfully
      end

      return cmd.status.pid
    end

    # Spawn the child process in a subshell
    #
    # @return [Fixnum] new child pid
    def respawn_child_fork
      cmd = File.join(self.rails_root, "script", "puma") + " server"
      redirects = export_fds()
      child_pid = fork { Dir.chdir(self.rails_root); exec(cmd, redirects) }
      Process.detach(child_pid)

      log "* started server process #{child_pid}"

      return child_pid
    end

  end # Base
end # PumaRunner
