
# rpc             make an rpc call and wait for the response and return it
# async_rpc       make an async rpc call
# wait_response   wait for a response with the given id

module Bixby
  module WebSocket

    class API

      include Bixby::Log
      attr_reader :ws

      def initialize(ws)
        @ws = ws
      end

      def open(event)
        # TODO extract Agent ID, if Agent
        logger.info "new client connected"
      end

      def close(event)
        logger.info "client disconnected"
      end

      def message(event)
        logger.info "got a message: #{event.data.ai}"
      end

    end

  end
end
