
module PumaRunner
  class SocketBinder < Puma::Binder

    def import_from_socket
      events = Puma::PidEvents.new($stdout, $stderr)

      filename = ENV["PUMA_INHERIT_SOCK"]
      return if filename.nil? or filename.empty?

      conn = UNIXSocket.open(filename)
      while true do
        str = conn.readline.strip
        if str == "_END_" then
          events.log("got _END_ string; done")
          break
        end

        # got a socket url, read io
        url = str
        events.log("going to recv_io for: #{url}")
        fd = conn.recv_io(TCPServer)
        events.log("got fd")

        # try to validate it first
        if !fd.kind_of?(IO) || fd.closed? then
          raise SocketError, "received an invalid socket fd"
        end

        @inherited_fds[url] = fd
      end
    end

  end
end
