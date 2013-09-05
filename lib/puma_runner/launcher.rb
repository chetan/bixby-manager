
module PumaRunner
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

      log "* stopping server gracefully..."
      Process.kill("QUIT", pid.read)
      while pid.exists? do
        sleep 0.1
      end
      log "* server stopped"
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
        log "* signalling server to restart"
        Process.kill("USR2", pid.read)
      end
    end

    # Status
    def do_status
      if pid.running? then
        STDOUT.puts "server is running"
      else
        STDOUT.puts "server is not running"
      end
    end

    # Thread dump
    def do_dump
      if not pid.running? then
        log "* server not running!"
        return
      end

      Process.kill("ALRM", pid.read)
    end

  end # Launcher
end # PumaRunner
