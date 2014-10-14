
module PumaRunner
  class SocketBinder < Puma::Binder

    def import_from_socket
      filename = ENV["PUMA_INHERIT_SOCK"]
      return if filename.nil? or filename.empty?

      conn = UNIXSocket.open(filename)
      while true do
        str = conn.readline.strip
        if str == "_END_" then
          break
        end

        # got a socket url, read io
        url = str
        fd = conn.recv_io
        @inherited_fds[url] = fd.to_i
      end
    end

  end
end
