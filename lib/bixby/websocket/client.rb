
require 'faye/websocket'
require 'eventmachine'

module Bixby
  module WebSocket

    class Client

      include Bixby::Log

      attr_reader :ws, :api

      def initialize(url)
        @url = url
      end

      def start
        EM.run {
          @ws = Faye::WebSocket::Client.new(@url)
          @api = Bixby::WebSocket::API.new(@ws)

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
        }
      end

    end

  end
end
