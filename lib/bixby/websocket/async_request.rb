
require 'thread'

module Bixby
  module WebSocket

    class AsyncRequest

      attr_reader :id

      def initialize(id)
        @id = id
        @mutex = Mutex.new
        @cond = ConditionVariable.new
        @response = nil
        @completed = false
      end

      # Set the response and signal any blocking threads
      #
      # @param [Object] obj       result of request, usually a JsonResponse
      def response=(obj)
        @mutex.synchronize {
          @completed = true
          @response = obj
          @cond.signal
        }
      end

      # Has the request completed?
      #
      # @return [Boolean] true if completed
      def completed?
        @completed
      end

      # Retrieve the response, blocking until it is available
      #
      # @return [Object] response data
      def response
        return @response if @completed
        @mutex.synchronize { @cond.wait(@mutex) }
        return @response
      end

    end

  end
end
