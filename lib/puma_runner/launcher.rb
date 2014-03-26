
module PumaRunner

  # Puma service control
  #
  # It's primary job is to spawn new processes (start) or interact with already running processes
  #
  # This class implements the following command line actions:
  # - start, stop, restart, zap, status, dump
  class Launcher < Base

    # Configure and start the server!
    def run!(cmd)
      $0 = "puma: launcher"

      cmd ||= "start"

      case cmd
        when "start"
          do_start()

        when "stop"
          do_stop()

        when "restart"
          do_restart()

        when "zap"
          do_zap()

        when "status"
          do_status()

        when "dump"
          do_dump()

       end

    end


    private

    # Start
    def do_start

      if pid.running? or @daemon_starter.starting? then
        error "server is already running!"
        return
      end

      self.binder = bind_sockets()
      respawn_child()
    end

    # Stop
    def do_stop
      if not pid.running? then
        log "* server not running!"
        if pid.exists? then
          pid.delete()
        end
        return
      end

      STDOUT.write "* stopping server gracefully... "
      Process.kill("QUIT", pid.read)
      while pid.exists? do
        sleep 0.1
      end
      STDOUT.puts "done"
    end

    # Restart
    def do_restart
      if not(pid.running? or @daemon_starter.starting?) then
        # not currently running or in the process of starting
        # issue a start command (spawn new server)
        do_start()

      elsif @daemon_starter.starting? then
        log "* a server is still trying to start!"

      elsif pid.running? then
        log "* signalling server #{pid.read} to restart (#{Time.new})"
        Process.kill("USR2", pid.read)
      end
    end

    # Zap - forcefully reset state to stopped
    def do_zap
      if @daemon_starter.starting? then
        @daemon_starter.cleanup!
      end

      if @pid.exists? then
        if @pid.running? then
          Process.kill(9, @pid.read)
        end
        @pid.delete()
      end
    end

    # Status
    def do_status
      if pid.running? then
        log "server is running"
      else
        log "server is not running"
      end
    end

    # Thread dump
    def do_dump
      if not pid.running? then
        log "* server not running!"
        return
      end

      puts "thread dump [should be] written to stderr: #{config.options[:redirect_stderr]}"
      Process.kill("ALRM", pid.read)
    end

  end # Launcher
end # PumaRunner
