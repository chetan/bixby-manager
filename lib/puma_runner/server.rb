
require 'bixby-common/util/signal'
require 'timeout'

module PumaRunner

  # Handles socket binding and passes control to Puma::Server
  # Takes care of trapping signals for graceful stop or restart
  class Server < Base

    def initialize
      super
      @events = Puma::PidEvents.new($stdout, $stderr)
    end

    # Redirect STDOUT/STDERR to files
    def redirect_io
      stdout = config.options[:redirect_stdout]
      stderr = config.options[:redirect_stderr] || stdout
      append = config.options[:redirect_append]

      if stdout
        STDOUT.reopen stdout, (append ? "a" : "w")
        STDOUT.sync = true
        STDOUT.puts "=== puma startup: #{Time.now} ==="
      end

      if stderr
        STDERR.reopen stderr, (append ? "a" : "w")
        STDERR.sync = true
        if stdout != stderr then
          # no need to dupe
          STDERR.puts "=== puma startup: #{Time.now} ==="
        end
      end
    end

    # Boot the Rails environment
    #
    # @return [Rack::Middleware]
    def boot_rails
      log "* Booting rails app"
      begin
        return config.app
      rescue Exception => e
        error ["Unable to load rails app!", e, e.backtrace].flatten.join("\n")
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

      Bixby::Signal.trap("QUIT") do
        log "* Shutting down on QUIT signal"
        do_stop()
      end

      Bixby::Signal.trap("USR2") do
        log "* Gracefully restarting on USR2 signal"
        do_restart()
      end

    end

    def run!
      return if not @daemon_starter.can_start?

      $0 = "puma: server (booting)"

      # trap_thread_dump() # in case we get stuck somewhere
      redirect_io()

      begin
        # bootstrap

        # don't boot EM during bootstrap - wait until after we daemonize
        # this seems to work best
        ENV["BIXBY_SKIP_EM"] = "1"

        self.app    = boot_rails()
        self.binder = bind_sockets()
        self.server = create_server(binder)

        # housekeeping
        old_pid_id = Process.pid
        Process.daemon(true, true)
        log "* Daemonized (pid changed #{old_pid_id} -> #{Process.pid})"
        pid.write
        setup_signals()

        # Start EM properly (i.e. at the proper time, which is now!)
        # TODO replace with startup callback?
        Bixby::AgentRegistry.redis_channel.start!

        # go!
        server.run

      rescue SocketError => ex
        log "* [FATAL] Caught SocketError: #{ex.message}\n" + ex.backtrace.join("\n")
        exit 1

      ensure
        @daemon_starter.cleanup!
      end

      log "* Server is up!"
      $0 = "puma: server (running)"
      server.thread.join
    end


    private

    # Stop
    def do_stop
      $0 = "puma: server (stopping)"
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

      # try up to 3 times to get it to start
      started = false
      (1..3).each do |try|
        $0 = "puma: server (spawning replacement, try #{try} of 3)"

        child_pid = respawn_child()

        # wait for child to come up fully
        begin

          p = nil
          Timeout.timeout(60) do
            @socket_passer.join

            # wait for the pid file to get updated with the new pid id
            # or for the startup lock to be cleared
            while true do
              p = @pid.read
              if !p.nil? && Process.pid != p && !@daemon_starter.starting? then
                break
              end
              sleep 1
            end
          end

          if Process.pid != @pid.read && @pid.running? then
            # pid file changed and daemon is running
            started = true
            break
          end

        rescue Timeout::Error
          # if we got here, kill the child process and try again
          log "* replacement startup timed out"
          if Pid.running?(child_pid) then
            Process.kill(9, child_pid) # kill!
          else
            log "* child process seems to have died"
          end
          @daemon_starter.cleanup! # nuke locks so we can try again

        end

      end # 3.times

      if !started then
        log "* failed to start after 3 tries.. bailing out!"
        $0 = "puma: server (running, respawn failed)"
        return
      end

      log "* replacement process started successfully, shutting down"

      $0 = "puma: server (winding down)"
      sleep 5

      server.begin_restart
      server.thread.join

      log "* Server shutdown complete"
    end

    # Delete the PID file if the PID within it is ours
    def delete_pid()
      if @pid.ours? then
        log "* deleting pid file since we own it"
        @pid.delete()
      end
    end

    # Setup thread dump signal
    # def trap_thread_dump
    #   # print a thread dump on SIGALRM
    #   # kill -ALRM `cat /var/www/bixby/tmp/pids/puma.pid`
    #   Signal.trap 'SIGALRM' do
    #     STDERR.puts "=== puma thread dump: #{Time.now} ==="
    #     STDERR.puts
    #     Thread.list.each do |thread|
    #       STDERR.puts "Thread-#{thread.object_id}"
    #       STDERR.puts thread.backtrace.join("\n    \\_ ")
    #       STDERR.puts "-"
    #       STDERR.puts
    #     end
    #     STDERR.puts "=== end puma thread dump ==="
    #   end
    # end

  end # Server
end # PumaRunner
