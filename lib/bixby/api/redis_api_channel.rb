
module Bixby
  class RedisAPIChannel < Bixby::APIChannel

    def initialize
      @responses = {}
      @started = @connected = false
      @thread_pool = Bixby::ThreadPool.new(:min_size => 1, :max_size => 8)
    end

    def connected?
      @connected
    end

    # Execute the given JsonRequest via some other host using Redis PubSub
    #
    # The request is published to the target host on a Redis channel and we
    # block until the response is returned.
    def execute(json_request, agent_id, host)
      fetch_response( execute_async(json_request, agent_id, host) )
    end

    def execute_async(json_request, agent_id, host)
      headers = {
        :agent_id => agent_id,
        :reply_to => AgentRegistry.hostname
      }
      req = Bixby::WebSocket::Request.new(json_request, nil, "rpc", headers)
      @responses[req.id] = Bixby::WebSocket::AsyncResponse.new(req.id)

      logger.debug { "execute_async:\n#{req.to_s}" }

      # try to publish request to host
      num = Sidekiq.redis{ |c| c.publish(host_key(host), req.to_wire) }
      if num == 0 then
        # TODO better ex
        raise "message published to 0 hosts!"
      end
      logger.debug "message published to #{num} hosts"

      req.id
    end

    # Fetch the response for the given request
    #
    # @param [String] request id
    #
    # @return [Object] JsonResponse
    def fetch_response(id)
      res = @responses[id].response
      @responses.delete(id)
      res
    end

    def publish_response(id, response)
      @responses[id].response = response
    end

    def start!

      if @started then
        logger.debug "PubSub already started!"
        return
      end

      logger.info "Starting Agent PubSub Channel"

      EM::Hiredis.reconnect_timeout = 1

      if EM.reactor_running? then
        logger.debug "EM already running, starting pubsub on next tick"
        EM.next_tick {
          start_pubsub()
        }

      else
        Thread.new {
          logger.debug "starting EventMachine runloop"
          EM.run {
            start_pubsub()
          }
          logger.debug "EventMachine run-loop exited"
        }
        # wait until reactor is up
        # adapted from faye-websocket
        while not EventMachine.reactor_running? do
          Thread.pass
        end
      end

      @started = true
    end # start!


    private

    def start_pubsub

      begin
        redis_host = BIXBY_CONFIG["redis"]
        (host, port) = redis_host.split(/:/)
        port ||= 6379
        @client = EM::Hiredis::PubsubClient.new(host, port.to_i)

        # subscribe to our channel when connected
        @client.on(:connected) do
          @connected = true
          logger.debug { "connected to redis; subscribing to redis api channel #{AgentRegistry.hostname}" }
          @client.subscribe(host_key(AgentRegistry.hostname)) do |msg|

            begin
              req = Bixby::WebSocket::Message.from_wire(msg)
              logger.debug { "new '#{req.type}' message" }

              case req.type
                when "rpc"
                  handle_rpc(req)
                when "rpc_result"
                  handle_rpc_result(req)
              end

            rescue Exception => ex
              logger.error ex
            end

          end
        end

        @client.on(:disconnected) do
          @connected = false
          logger.warn "lost connection to redis server #{redis_host}; reconnecting..."
        end

        @client.on(:reconnect_failed) do |fail_count|
          if fail_count % 30 == 0 then
            logger.warn "still trying to reconnect to #{redis_host} (#{fail_count} attempts so far)..."
          elsif @connected == false && fail_count == 1 then
            logger.warn "failed to connect to redis server #{redis_host}; retrying..."
          end
        end

        @client.connect

      rescue Exception => ex
        logger.error "Error starting PubSub client"
        logger.error ex
      end

      RedisAPIChannel.logger.debug { "started PubSub client" }

    end

    def handle_rpc(req)
      logger.debug { "got request for agent #{req.headers["agent_id"]}" }

      # Execute the requested method and return the result
      agent_id = req.headers["agent_id"]
      api = AgentRegistry.get(agent_id)
      if api.nil? then
        # TODO
      end

      # Release the thread that received the RPC request by quickly
      # firing the request off to the Agent in another background
      # thread.
      @thread_pool.perform do
        logger.debug "handling json_req in background thread"

        api.execute_async(req.json_request) do |json_res|
          # wrap and publish to requesting client
          res = Bixby::WebSocket::Response.new(json_res, req.id).to_wire
          reply_to = req.headers["reply_to"]
          num = Sidekiq.redis{ |c| c.publish(host_key(reply_to), res) }
          logger.debug { "published response to #{reply_to} : received by #{num} hosts" }
        end
      end
    end

    def handle_rpc_result(req)
      # Pass the result back to the caller
      # need to get the actual instance of this class since we are running in a callback
      # AgentRegistry.redis_channel.responses[req.id].response = JsonResponse.from_json(req.body)
      res = JsonResponse.from_json(req.body)
      logger.debug{ res.to_s }
      publish_response(req.id, res)
    end


    # Get the redis PubSub channel key for the given host
    #
    # @param [String] host
    #
    # @return [String] channel key
    def host_key(host)
      "bixby:agents:exec:#{host}"
    end

  end
end
