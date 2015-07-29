
require 'faye/websocket'

module Bixby
  class WebSocketServer

    include Bixby::Log

    def initialize
      @thread_pool = Bixby::ThreadPool.new(:min_size => 1, :max_size => 8)
    end

    def call(env)

      if not Faye::WebSocket.websocket?(env) then
        # Redirect the client to the Rails application, if the request
        # is not a WebSocket
        return [301, { 'Location' => '/'}, []]
      end

      ws = Faye::WebSocket.new(env)
      api = Bixby::WebSocket::APIChannel.new(ws, ServerHandler, @thread_pool)

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
