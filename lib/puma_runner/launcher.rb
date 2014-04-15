
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
          log "puma_launcher: start @ #{Time.new}"
          do_start()

        when "stop"
          log "puma_launcher: stop @ #{Time.new}"
          do_stop()

        when "restart"
          log "puma_launcher: restart @ #{Time.new}"
          do_restart()

        when "zap"
          log "puma_launcher: zap @ #{Time.new}"
          do_zap()

        when "status"
          do_status()

        when "dump"
          do_dump()

        else
          do_help()

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
        if pid.exists? then
          pid.delete()
        end

        # look for dangling pids
        pids = pid.find
        if !pids.empty? then
          warn "* found the following dangling pids: " + pids.join(", ")
          pids.each do |p|
            log "* sending QUIT signal to #{p}"
            Process.kill("QUIT", p)
          end
          return
        end

        log "* server not running!"
        return
      end

      pid_id = pid.read
      STDOUT.write "* stopping server #{pid_id} gracefully (sending QUIT)... "
      Process.kill("QUIT", pid_id)
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

      if pid.exists? then
        if pid.running? then
          warn "* Killing server at #{pid.read}"
          Process.kill(9, pid.read)
        end
        pid.delete()
      else
        # look for dangling pids
        pids = pid.find
        pids.each do |p|
          warn "* Killing dangling server at #{p}"
          Process.kill(9, p)
        end
      end
    end

    # Status
    def do_status
      if pid.exists? then

        if pid.running? then
          log "server #{pid.read} is running"
        else
          log "server is not running; pid file exists, but found stale pid #{pid.read}"
          begin
            pid.delete
          rescue
          end
          exit 1
        end

      else

        # try to find via ps
        ps = pid.ps
        if !ps.empty? then
          warn "WARNING: pid file not found, but found the following processes:"
          warn ""
          ps.each{ |s| warn s }
          warn ""
          exit 2
        end

        log "server is not running; pid file not found"
        exit 1
      end

    end

    # Thread dump
    def do_dump
      if not pid.running? then
        log "* server not running!"
        return
      end

      puts "thread dump written to stderr: #{config.options[:redirect_stderr]}"
      Process.kill("ALRM", pid.read)
    end

    def do_help

      puts <<-EOF
puma launcher

usage: bundle exec script/puma start|stop|restart|zap|status|dump

commands:

start               start the server, unless already started
stop                stop the server gracefully, if running
restart             restart the server gracefully, if running
zap                 forcefully stop the server (kill -9 and delete pid file)
status              see if server is running (via pid and `ps`)
dump                thread dump to stderr
EOF


    end

  end # Launcher
end # PumaRunner
