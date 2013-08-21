
module Bixby
  module WebSocket

    class Server

      extend Bixby::Log

      @conns = {}

      def self.call(env)

        if not Faye::WebSocket.websocket?(env) then
          # Redirect the client to the Rails application, if the request
          # is not a WebSocket
          [301, { 'Location' => '/'}, []]
        end

        ws = Faye::WebSocket.new(env)
        api = Bixby::WebSocket::API.new(ws)
        # @conns << ws

        ws.on :open do |e|
          begin
            api.open(e)
          rescue Exception => ex
            logger.error ex
          end
        end

        ws.on :message do |e|
          begin
            api.message(e)
          rescue Exception => ex
            logger.error ex
          end
        end

        # Kill the thread when client disconnects and remove the websocket
        ws.on :close do |e|
          begin
            api.close(e)
          rescue Exception => ex
            logger.error ex
          end
        end

        ws.rack_response
      end # call

    end

end
end
