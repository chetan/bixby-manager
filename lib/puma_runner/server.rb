
require 'bixby-common/util/signal'
require 'bixby-common/util/thread_dump'
require 'timeout'

module PumaRunner

  # Handles socket binding and passes control to Puma::Server
  # Takes care of trapping signals for graceful stop or restart
  class Server < Base

    def initialize
      super
      @events = PidEvents.new($stdout, $stderr)
    end

    # Redirect STDOUT/STDERR to files
    def redirect_io
      stdout = config.options[:redirect_stdout]
      stderr = config.options[:redirect_stderr] || stdout
      append = config.options[:redirect_append]

      if stdout
        STDOUT.reopen stdout, (append ? "a" : "w")
        STDOUT.sync = true
        STDOUT.puts "=== puma #{::Puma::Const::PUMA_VERSION} startup: #{Time.now} ==="
      end

      if stderr
        STDERR.reopen stderr, (append ? "a" : "w")
        STDERR.sync = true
        if stdout != stderr then
          # no need to dupe
          STDERR.puts "=== puma #{::Puma::Const::PUMA_VERSION} startup: #{Time.now} ==="
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

      redirect_io()
      temp_thread = Bixby::ThreadDump.trap!

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

        # kill old thread and trap again after daemonizing
        temp_thread.kill
        Bixby::ThreadDump.trap!

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
        started = wait_for_child(child_pid)
        break if started
      end

      if !started then
        log "* failed to start after 3 tries.. bailing out!"
        $0 = "puma: server (running, respawn failed)"
        return
      end

      log "* replacement process started successfully, shutting down"

      $0 = "puma: server (winding down)"
      # sleep 5

      server.begin_restart
      server.thread.join

      log "* Server shutdown complete"
    end

    # wait for child to come up fully
    def wait_for_child(child_pid)
      begin

        p = nil
        Timeout.timeout(60) do

          # wait for SocketPasser to finish its job (means new proc started up)
          # AND wait for the pid file to get updated with the new pid id
          # AND for the startup lock to be cleared
          while true do
            if !Pid.running?(child_pid) && @socket_passer.join(1).nil? then
              # new process died but SocketPasser is still waiting/working, bail out
              # (pid changes when daemonizing so we need to do the extra check)
              raise Timeout::Error
            end
            p = @pid.read
            if @socket_passer.join(0.1) && !p.nil? && Process.pid != p && !@daemon_starter.starting? then
              break
            end
            sleep 1
          end
        end

        if Process.pid != @pid.read && @pid.running? then
          # pid file changed and daemon is running
          return true
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

      false
    end

    # Delete the PID file if the PID within it is ours
    def delete_pid()
      if @pid.ours? then
        log "* deleting pid file since we own it"
        @pid.delete()
      end
    end

  end # Server
end # PumaRunner
