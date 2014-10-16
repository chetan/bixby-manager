
module PumaRunner
  class SocketPasser

    def initialize(binder)
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
        client.puts(bind_url)
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
