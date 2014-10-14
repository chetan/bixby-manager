
module PumaRunner
  class SocketPasser

    def initialize(binder)
      @binder = binder
      @thread = nil
    end

    def start
      ENV["PUMA_INHERIT_SOCK"] = @sock = random_sockname()
      @server = UNIXServer.new(@sock)
      @thread = Thread.new do
        begin
          client = @server.accept
          pass_sockets(client)

        rescue Exception => ex
          puts "caught #{ex}"
        end
      end
    end

    def join
      @thread && @thread.join
    end

    def stop
      @thread && Thread.kill(@thread)
    end


    private

    def pass_sockets(client)
      @binder.listeners.each_with_index do |(bind_url,io),i|
        client.puts(bind_url)
        client.send_io(io)
      end
      client.puts "_END_"
    end

    def random_sockname
      t = Tempfile.new("puma-sockets")
      f = t.path
      t.close!
      return f + ".sock"
    end

  end
end
