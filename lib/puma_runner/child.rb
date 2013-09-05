
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


    def run!
      $0 = "puma: server"
      self.config = load_config()

      self.app    = boot_rails()

      self.binder = bind_sockets()
      self.server = create_server(binder)

      # go!
      events.log("* Server is up!")
      server.run.join
    end

  end # Child
end # PumaRunner
