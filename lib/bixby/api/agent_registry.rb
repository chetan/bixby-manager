
module Bixby

  class AgentRegistry

    extend Bixby::Log

    class << self

      def agents
        @agents ||= {}
      end

      def hostname
        # add a random number hostname so we can have a unique listener for
        # every process.
        @hostname ||= (`hostname`.strip + "-" + SecureRandom.random_number(100000).to_s)
      end

      # Add an Agent to the registry
      #
      # @param [Agent] agent
      # @param [Bixby::WebSocket::APIChannel] api
      def add(agent, api)
        logger.debug { "registering agent #{agent.id}"}
        agents[agent.id] = api
        # TODO don't use sidekiq, just convenient for now
        Sidekiq.redis { |c| c.hset("bixby:agents", agent.id, hostname) }
        logger.debug { "registered agents: #{agents.keys.join(' ')}" }
      end

      # Remove the given channel (and agent) from the registry
      #
      # @param [Bixby::WebSocket::APIChannel] api
      def remove(api)
        logger.debug { "deleting disconnected agent" }
        agents.each do |key, val|
          if val == api then
            agents.delete(key)
            Sidekiq.redis { |c| c.hdel("bixby:agents", key) }
          end
        end
        logger.debug { "remaining agents: #{agents.keys.join(' ')}"}
      end

      # Get an APIChannel for the given Agent
      #
      # @param [Agent] agent
      #
      # @return [Bixby::WebSocket::APIChannel]
      def get(agent)
        agents[ agent_id(agent) ]
      end

      # Find which host the given agent is on
      #
      # @param [Agent] agent
      #
      # @return [String] host the agent is on
      def find(agent)
        agent_host = Sidekiq.redis { |c| c.hget("bixby:agents", agent_id(agent)) }
      end

      # Execute a JsonRequest on the given Agent via the given Host. Returns
      # the response in a synchronous manner.
      #
      # @param [Agent] agent
      # @param [String] host      hostname
      # @param [Bixby::JsonRequest] json_request
      #
      # @return [Bixby::JsonResponse]
      def exec_remote(agent, host, json_request)
        return redis_channel.execute(json_request, agent_id(agent), host)
      end

      def redis_channel
        @redis_channel ||= RedisAPIChannel.new
      end


      private

      # Convert given param to an Agent ID
      #
      # @param [Agent, Fixnum] agent
      #
      # @return [Fixnum] agent id
      def agent_id(agent)
        return agent.id if agent.kind_of? Agent
        return agent
      end

    end
  end

end
