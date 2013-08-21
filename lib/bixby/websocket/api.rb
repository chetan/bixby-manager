
require "bixby/websocket/async_request"

module Bixby
  module WebSocket

    class API

      include Bixby::Log
      attr_reader :ws

      def initialize(ws)
        @ws = ws
        @requests = {}
      end

      # Perform RPC

      # Perform the given RPC request and return the response
      #
      # @param [String] operation
      # @param [Array] params
      #
      # @return [Object] JsonResponse
      def rpc(operation, params)
        fetch_response( async_rpc(operation, params) )
      end

      # Make an asynchronous RPC request
      #
      # @param [String] operation
      # @param [Array] params
      #
      # @return [String] request id
      def async_rpc(operation, params)
        id = SecureRandom.uuid
        @requests[id] = AsyncRequest.new(id)
        cmd = { :type => "rpc", :id => id, :operation => operation, :params => params}
        ws.send(MultiJson.dump(cmd))
        id
      end

      # Fetch the response for the given request
      #
      # @param [String] request id
      #
      # @return [Object] JsonResponse
      def fetch_response(id)
        res = @requests[id].response
        @requests.delete(id)
        res
      end


      # Handle channel events

      def open(event)
        # TODO extract Agent ID, if Agent
        logger.info "new channel opened"
      end

      def close(event)
        logger.info "client disconnected"
      end

      def message(event)
        logger.info "got a message: #{event.data.ai}"
        cmd = MultiJson.load(event.data)

        if cmd["type"] == "rpc" then
          do_rpc(cmd)

        elsif cmd["type"] == "rpc_result" then
          do_result(cmd)
        end
      end


      private

      def do_rpc(cmd)
        response = { :type => "rpc_result", :id => cmd["id"], :data => SecureRandom.random_number(100) }
        ws.send(MultiJson.dump(response))
      end

      def do_result(cmd)
        id = cmd["id"]
        @requests[id].response = cmd["data"]
      end

    end

  end
end
