
require 'timeout'

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
          log "puma_launcher: start"
          do_start()

        when "stop"
          log "puma_launcher: stop"
          do_stop()

        when "restart"
          log "puma_launcher: restart"
          do_restart()

        when "zap"
          log "puma_launcher: zap"
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
      begin
        Timeout::timeout(60) do
          respawn_child()
          @socker_passer.join
        end
      rescue Timeout::Error => ex
        error "timed out (60 sec) waiting for server to start!"
        exit 1
      end
    end

    # Stop
    def do_stop

      found = false
      if pid.exists? then
        if pid.running? then
          found = true
          pid_id = pid.read
          STDOUT.write "* stopping server #{pid_id} gracefully (sending QUIT)... "
          Process.kill("QUIT", pid_id)
          while Pid.running? pid_id do
            sleep 0.1
          end
          STDOUT.puts "done"
        end

        begin
          pid.delete()
        rescue
        end
      end

      # look for dangling pids
      pids = pid.find
      if !pids.empty? then
        found = true
        log "* found the following dangling pids: " + pids.join(", ")
        pids.each do |p|
          log "* sending QUIT signal to #{p}"
          Process.kill("QUIT", p)
        end
        return
      end

      log "* server not running!" if !found
    end

    # Restart
    def do_restart
      if not(pid.running? or @daemon_starter.starting?) then
        # not currently running or in the process of starting

        ps = pid.find
        if !ps.empty? then
          # found dangling servers
          if ps.size > 1 then
            log "* found more than 1 dangling process! bailing out"
            exit 1
          end

          log "* found a dangling process"
          log "* signalling server #{ps.first} to restart"
          Process.kill("USR2", ps.first)
          return
        end

        # issue a start command (spawn new server)
        do_start()

      elsif @daemon_starter.starting? then
        log "* a server is still trying to start!"

      elsif pid.running? then
        log "* signalling server #{pid.read} to restart"
        Process.kill("USR2", pid.read)
      end
    end

    # Zap - forcefully reset state to stopped
    def do_zap
      if @daemon_starter.starting? then
        @daemon_starter.cleanup!
      end

      count = 0

      if pid.exists? then
        if pid.running? then
          log "* Killing server at #{pid.read}"
          Process.kill(9, pid.read)
        end
        pid.delete()
        count += 1
      end

      # look for dangling pids
      pids = pid.find
      pids.each do |p|
        log "* Killing dangling server at #{p}"
        Process.kill(9, p)
        count += 1
      end

      log "done (#{count} processes killed)"
    end

    # Status
    def do_status
      current_pid = pid.read
      if pid.exists? then
        log "found pid file with pid #{current_pid}"

        if pid.running? then
          log "server #{current_pid} is running"
        else
          log "server is not running, deleting stale pid file"
          begin
            pid.delete
          rescue
          end
        end

      else
        log "no pid file found"
      end

      # try to find via ps
      ps = pid.ps.reject{ |s| s.split(/\s+/)[1].strip.to_i == current_pid }
      if !ps.empty? then
        log "WARNING: found the following dangling processes:"
        log ""
        ps.each{ |s| log s }
        log ""
        exit 2
      end

      exit 1 if !current_pid.nil?
      log "server is not running: pid file does not exist and no processes found"
      exit 1
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
