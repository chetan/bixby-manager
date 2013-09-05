
module PumaRunner
  class Child < Base

    # Boot the Rails environment
    #
    # @return [Rack::Middleware]
    def boot_rails
      log "* Booting rails app"
      begin
        return config.app
      rescue Exception => e
        error "Unable to load rails app!"
        error e
        error e.backtrace.join("\n")
        exit 1
      end
    end

    # Create the server
    def create_server(binder)
      server = Puma::Server.new app, events, config.options
      server.min_threads = config.options[:min_threads]
      server.max_threads = config.options[:max_threads]
      server.inherit_binder(binder)

      if config.options[:mode] == :tcp
        server.tcp_mode!
      end

      unless "development" == config.options[:environment]
        server.leak_stack_on_error = false
      end

      server
    end

    # Setup daemon signals
    def setup_signals

      Signal.trap("QUIT") do
        log "* Shutting down on QUIT signal"
        do_stop()
      end

      Signal.trap("USR2") do
        log "* Graceful restart on USR2 signal"
        do_restart()
      end

    end

    def run!
      $0 = "puma: server"
      trap_thread_dump() # in case we get stuck somewhere

      return if not @daemon_starter.can_start?

      begin
        # bootstrap

        # don't boot EM during bootstrap - wait until after we daemonize
        # this seems to work best
        ENV["BIXBY_SKIP_EM"] = "1"

        self.app    = boot_rails()
        self.binder = bind_sockets()
        self.server = create_server(binder)

        # housekeeping
        Process.daemon(true, true)
        pid.write
        setup_signals()

        # Start EM properly (i.e. at the proper time, which is now!)
        Bixby::AgentRegistry.redis_channel.start!

        # go!
        server.run

      ensure
        @daemon_starter.cleanup!
      end

      log("* Server is up! (pid=#{Process.pid})")
      server.thread.join
    end


    private

    # Stop
    def do_stop
      # stop puma
      server.stop(true)

      # stop EM
      if EM.reactor_running? then
        EM.stop_event_loop
        while EM.reactor_running? do
          # wait for it to shut down
          Thread.pass
        end
      end

      # finally, cleanup
      delete_pid()

      # exit 0 # force exit?
    end

    # Restart
    def do_restart()

      # First spawn a replacement node and pass it our FDs
      # then tell this server to quit

      respawn_child()

      # wait for child to come up fully
      while Process.pid == @pid.read || @daemon_starter.starting? do
        sleep 1
      end

      server.begin_restart
      server.thread.join

      log "* Server shutdown complete (pid=#{Process.pid})"
    end

    # Delete the PID file if the PID within it is ours
    def delete_pid()
      if @pid.ours? then
        @pid.delete()
      end
    end

    # Setup thread dump signal
    def trap_thread_dump
      # print a thread dump on SIGALRM
      # kill -ALRM `cat /var/www/bixby/tmp/pids/puma.pid`
      Signal.trap 'SIGALRM' do
        Thread.list.each do |thread|
          STDERR.puts "Thread-#{thread.object_id.to_s(36)}"
          STDERR.puts thread.backtrace.join("\n    \\_ ")
          STDERR.puts "-"
          STDERR.puts
        end
      end
    end

  end # Child
end # PumaRunner
