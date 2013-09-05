
module PumaRunner
  class Master < Base

    attr_accessor :child_pids

    def initialize
      super
      @child_pids = []
    end

    # Export the file descriptors into the ENV for use by child processes
    def export_fds
      redirects = {:close_others => true}
      self.binder.listeners.each_with_index do |(bind,io),i|
        ENV["PUMA_INHERIT_#{i}"] = "#{io.to_i}:#{bind}"
        redirects[io.to_i] = io.to_i
      end
      redirects
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

    # Spawn the child process
    def spawn_child
      cmd = PUMA_SCRIPT + " start_child"
      redirects = export_fds()
      child_pids << fork { exec(cmd, redirects) }
      events.log "* started child process #{child_pids.last}"
    end

    # Configure and start the server!
    def run!
      $0 = "puma: launcher"
      self.config = load_config()

      # bind first because booting rails is slow.. this way we can throw an error
      # as early as possible
      self.binder = bind_sockets()

      setup_signals()
      spawn_child()

      # wait for children to exit (never)
      Process.waitall
    end

  end # Master
end # PumaRunner
