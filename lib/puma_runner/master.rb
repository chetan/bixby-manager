
module PumaRunner
  class Master < Base

    attr_accessor :child_pids

    def initialize
      super
      @child_pids = []
    end

    # PASS FD TO ANOTHER PROCESS VIA UNIX SOCKET
    def start_fd_listener
      @pass_fd = UNIXServer.new("/tmp/puma_fd.sock")
      ENV["PUMA_PASS_FD"] = @pass_fd.path
      Thread.new {
        begin

          while true do
              sock = @pass_fd.accept
              binder.listeners.each_with_index do |(bind,io),i|
                # puts "exporting #{bind} on FD #{io.to_i} to socket client"
                sock.puts(bind)
                sock.send_io(io)
              end
              sock.close
          end

        ensure
          # cleanup fd server
          File.unlink(@pass_fd.path)
        end
      }
    end

    # Configure and start the server!
    def run!(cmd)
      $0 = "puma: launcher"

      cmd ||= "start"
      puts cmd

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

    def do_start
      self.binder = bind_sockets()
      respawn_child()
    end

    def do_stop
      if not pid.running? then
        log "* server not running!"
        if pid.exists? then
          pid.delete()
        end
        return
      end

      log "* stopping server gracefully"
      Process.kill("QUIT", pid.read)
      while pid.exists? do
        sleep 0.1
      end
      log "* server stopped"
    end

    def do_dump
      if not pid.running? then
        log "* server not running!"
        return
      end

      Process.kill("ALRM", pid.read)
    end

  end # Master
end # PumaRunner
