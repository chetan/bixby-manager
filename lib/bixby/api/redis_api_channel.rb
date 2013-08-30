
module Bixby
  class RedisAPIChannel < Bixby::APIChannel

    def initialize
      @responses = {}
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
      # reactor will be started by Puma, simply schedule the connection on the
      # next tick

      ensure_reactor_running()

      EM.next_tick {

        begin
          (host, port) = BIXBY_CONFIG["redis"].split(/:/)
          port ||= 6379
          @client = EM::Hiredis::PubsubClient.new(host, port.to_i)
          @client.connect

          @client.subscribe(host_key(AgentRegistry.hostname)) do |msg|

            begin
              req = Bixby::WebSocket::Message.from_wire(msg)
              logger.debug { "new '#{req.type}' message" }

              if req.type == "rpc" then
                logger.debug { "got request for agent #{req.headers["agent_id"]}" }

                # Execute the requested method and return the result
                agent_id = req.headers["agent_id"]
                api = AgentRegistry.get(agent_id)
                if api.nil? then
                  # TODO
                end

                # Release the thread that received the RPC request by quickly
                # firing the request off to the Agent in another background
                # thread. The Agent's response will be returend by EM via
                # callback.
                EM.defer {
                  logger.debug "executing json_req in defer thread"

                  api.execute_async(req.json_request) do |json_res|
                    # wrap and publish to requesting client
                    res = Bixby::WebSocket::Response.new(json_res, req.id).to_wire
                    reply_to = req.headers["reply_to"]
                    num = Sidekiq.redis{ |c| c.publish(host_key(reply_to), res) }
                    logger.debug { "published response to #{reply_to}" }
                  end

                  logger.debug "defer thread complete; callback created"
                }

              elsif req.type == "rpc_result" then
                # Pass the result back to the caller
                # need to get the actual instance of this class since we are running in a callback
                # AgentRegistry.redis_channel.responses[req.id].response = JsonResponse.from_json(req.body)
                res = JsonResponse.from_json(req.body)
                logger.debug(res.to_s)
                publish_response(req.id, res)

              end

            rescue => ex
              logger.error ex
            end
          end

        rescue Exception => ex
          logger.error "Error starting PubSub client"
          logger.error ex
        end

        RedisAPIChannel.logger.debug { "started PubSub client" }
      }
    end # start!


    private

    # Make sure EventMachine is running. Depending on the environment we're
    # running in, EM may or may not have been started already. This should
    # should ensure that we play nicely with others.
    #
    # Borrowed from faye-websocket
    def ensure_reactor_running
      if not EM.reactor_running? then
        Thread.new { EventMachine.run }
        Thread.pass until EventMachine.reactor_running?
        logger.debug "started EventMachine"
      else
        logger.debug "EM already running"
      end
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
