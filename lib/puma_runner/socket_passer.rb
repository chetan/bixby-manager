
module PumaRunner
  class SocketPasser

    def initialize(binder)
      @events = PidEvents.new($stdout, $stderr)
      @binder = binder
      @thread = nil
    end

    # Try to validate that our listener sockets are all in working order
    def test_sockets
      begin
        return false if @binder.listeners.empty?
        @binder.listeners.each_with_index do |(bind_url,io),i|
          if !(io && io.kind_of?(IO) && !io.closed?) then
            return false
          end
        end
      rescue Exception => ex
        return false
      end

      return true
    end

    def start
      ENV["PUMA_INHERIT_SOCK"] = @sock = random_sockname()
      @server = UNIXServer.new(@sock)
      @thread = Thread.new do
        client = nil
        begin
          client = @server.accept
          @events.log("[Passer] got client")
          pass_sockets(client)

        rescue Exception => ex
          puts "caught #{ex}"
        ensure
          cleanup(client)
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

    def cleanup(client)
      begin
        client.close if client && !client.closed?
      rescue
      end

      begin
        @server.close if !@server.closed?
      rescue
      end

      begin
        File.unlink(@sock)
      rescue
      end
    end

    def pass_sockets(client)
      @binder.listeners.each_with_index do |(bind_url,io),i|
        io.autoclose = false
        @events.log("[Passer] sending url #{bind_url.strip}")
        client.puts(bind_url.strip)
        @events.log("[Passer] sending io #{io.inspect}")
        client.send_io(io)
      end
      client.puts "_END_"
    end

    def random_sockname
      t = Tempfile.new("puma-launcher-")
      f = t.path
      t.close!
      return f + ".sock"
    end

  end
end
