
module Bixby

  class AgentRegistry

    extend Bixby::Log

    class << self

      def active?
        @active = true if @active.nil? # starting to wish I used a singleton here instead
        redis_channel.connected? && @active
      end

      def agents
        @agents ||= {}
      end

      def hostname
        @hostname ||= generate_hostname()
      end

      # Shut down the registry
      #
      # Do not allow further connections to be added and drop all existing agents
      def shutdown!
        return if !active?
        @active = false
        dump_all
      end

      # In development mode, we trap the INT signal (^C) in order to properly cleanup agent
      # connections before exiting
      def trap_signals
        return if @trapped || !Rails.env.development?

        Bixby::Signal.trap("INT") do
          # we dump all connections here *before* exiting because otherwise Rails will rollback
          # our transactions when it sees that Threads are in the process of aborting/exiting.
          logger.warn "running cleanup on SIGINT"
          shutdown!
          logger.warn "cleanup finished; exiting"
          exit
        end

        @trapped = true
      end

      # Add an Agent to the registry
      #
      # @param [Agent] agent
      # @param [Bixby::WebSocket::APIChannel] api
      #
      # @return [Boolean] whether or not the agent was successfully added
      def add(agent, api)
        return false if !active?

        # we setup our trap now so we can make sure we are not overriden by rails/puma
        # we need this signal to properly cleanup before shutdown
        trap_signals()

        agents[agent.id] = api
        # TODO don't piggyback sidekiq connection, just convenient for now
        Sidekiq.redis { |c| c.hset("bixby:agents", agent.id, hostname) }
        touch_agent(agent, true)
        logger.debug { "added agent #{agent.id}; now: #{agents.keys.inspect}" }
        true
      end

      # Remove the given channel (and agent) from the registry
      #
      # @param [Bixby::WebSocket::APIChannel] api
      def remove(api)
        removed = 0
        agents.each do |key, val|
          if val == api then
            removed += 1
            agents.delete(key)
            Sidekiq.redis { |c| c.hdel("bixby:agents", key) }
            touch_agent(key, false)
          end
        end
        return if removed == 0
        logger.debug { "removed agent; now: #{agents.keys.inspect}" }
      end

      # Disconnect all agents
      #
      # In the event that redis becomes unavailable, we must disconnect all
      # connected agents so we can handle requests properly when it comes back
      def dump_all
        return if agents.empty?
        logger.debug { "dumping all agent connections" }
        agents.delete_if do |id, api|
          begin
            api.ws.close()
            api.close(nil)
            Sidekiq.redis { |c| c.hdel("bixby:agents", key) }
          rescue Exception => ex
            # ignore since redis is probably down
          end
          touch_agent(id, false)
          true
        end
        logger.debug { "dumped all agents" }
      end

      # Get an APIChannel for the given Agent
      #
      # @param [Agent] agent
      #
      # @return [Bixby::WebSocket::APIChannel]
      def get(agent)
        agents[ agent_id(agent) ]
      end

      # Execute a request on the given Agent, whether it is connected locally or
      # to some other host.
      #
      # @param [Agent] agent
      # @param [Bixby::JsonRequest] json_request
      #
      # @return [Bixby::JsonResponse]
      def execute(agent, json_request)
        api = get(agent)
        if api then
          # execute via locally connected agent
          return api.execute(json_request)

        else
          # execute via agent connected to some other host
          host = find(agent)
          if host.nil? then
            raise AgentException, "agent not online"
          end
          return exec_remote(agent, host, json_request)
        end
      end

      # Find which host the given agent is on
      #
      # @param [Agent] agent
      #
      # @return [String] host the agent is on
      def find(agent)
        return Sidekiq.redis { |c| c.hget("bixby:agents", agent_id(agent)) }
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

      # Update the seen/connected status
      #
      # @param [Agent] agent
      # @param [Boolean] connected        whether or not the agent is connected
      def touch_agent(agent, connected)
        agent = Agent.find(agent) if not agent.kind_of? Agent
        agent.last_seen_at = Time.new
        agent.is_connected = connected

        if connected && agent.version.blank? then
          # hack to get the proper version # for upgraded hosts
          #
          # when an agent is upgraded to >= 0.2.0 and we don't know the version # yet
          # just assume it's at least 0.2.0 (the first to support websockets)
          # then schedule a version update in a few seconds
          #
          # also force the monitoring config to be updated so we can install the new service script
          agent.version = "0.2.0"
          Bixby::Inventory.defer(10).update_version(agent.host.id)
          Bixby::Monitoring.defer(20).update_check_config(agent.id)
        end

        agent.save
      end

      # Get system's hostname
      def generate_hostname
        cmd = Mixlib::ShellOut.new("hostname")
        cmd.run_command

        # add a random number hostname so we can have a unique listener for
        # every process.
        return (cmd.stdout.strip + "-" + SecureRandom.random_number(100000).to_s)
      end

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
