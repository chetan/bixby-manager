
module PumaRunner
  class Child < Base

    # # Bind to sockets opened by parent
    # def bind_sockets

    #   binder = Puma::Binder.new(events)

    #   UNIXSocket.open(ENV["PUMA_PASS_FD"]) do |sock|
    #     bind = sock.readline
    #     io = sock.recv_io()

    #     # add to binder
    #     tcp_io = TCPServer.for_fd(io.to_i)
    #     init_tcp(tcp_io)
    #     io.reopen(tcp_io)

    #     binder.ios << tcp_io
    #     binder.listeners << [bind, tcp_io]
    #     # tcp_io.listen(1024)
    #     # tcp_io.listen(1024)


    #     # puts "accepting off tcp_io"
    #     # s = tcp_io.accept
    #     # puts "got a client@"
    #     # while true do
    #     #   puts s.readline
    #     # end

    #   end

    #   binder
    # end

    def init_tcp(s)
      optimize_for_latency=true
      backlog=1024
      if optimize_for_latency
        s.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
      end
      s.setsockopt(Socket::SOL_SOCKET,Socket::SO_REUSEADDR, true)
      s.listen backlog
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

      # Start EM properly
      Bixby::AgentRegistry.redis_channel.start!

      # go!
      log("* Server is up!")
      server.run.join
    end


    private

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

    def do_restart()
      # server.begin_restart
    end

    # Delete the PID file if the PID within it is ours
    def delete_pid()
      if @pid.ours? then
        @pid.delete()
      end
    end

    def trap_thread_dump
      # print a thread dump on SIGALRM
      # kill -ALRM `cat /var/www/bixby/tmp/pids/puma.pid`
      trap 'SIGALRM' do
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
