
require "semver"

module Bixby

class RemoteExec < API

  module Methods

    include HttpClient
    include Crypto

    # Execute a command on an Agent, automatically provisioning it if necessary
    #
    # @param [Agent] agent
    # @param [CommandSpec] command
    #
    # @return [CommandResponse]
    def exec(agent, command)

      agent = get_model(agent, Agent)
      command = create_spec(command)

      ret = exec_internal(agent, command)

      if ret.success? || ret.code != 404 then
        return CommandResponse.from_json_response(ret)
      end

      # try to provision it, then try again
      ret = Provisioning.new.provision(agent, command)
      if not ret.success? then
        return CommandResponse.from_json_response(ret) # TODO raise err?
      end

      # try to exec again
      ret = exec_internal(agent, command)
      return CommandResponse.from_json_response(ret)
    end

    # Convert various inputs to a CommandSpec wrapper
    #
    # @param [Object] command Can be a Hash/Command/String/CommandSpec
    # @return [CommandSpec]
    def create_spec(command)
      spec = if command.kind_of? CommandSpec then
        command
      elsif command.kind_of? Command then
        command.to_command_spec
      elsif command.kind_of? Hash then
        CommandSpec.new(command)
      elsif command.kind_of? String then
        CommandSpec.from_json(command)
      elsif command.kind_of? Fixnum then
        Command.find(command).to_command_spec
      else
        command
      end

      if !spec.command.blank? then
        # load user/group config
        manifest = spec.manifest
        if !manifest.blank? then
          spec.user = manifest["user"]
          spec.group = manifest["group"]
        end
      end

      spec
    end


    private

    # Execute a command on an Agent. Does not try to provision on failure
    #
    # @param [Agent] agent
    # @param [CommandSpec] command
    #
    # @return [JsonResponse]
    def exec_internal(agent, command)
      json_res = exec_api(agent, "shell_exec", command.to_hash)
      CommandLog.create(agent, command, json_res)
      return json_res
    end

    # Execute the given API request on an Agent. Will not try to provision;
    # simply returns any errors.
    #
    # NOTE: This 'raw' method should only be called by #exec_internal
    #
    # @param [Agent] agent
    # @param [String] operation
    # @param [*Array] params
    #
    # @return [JsonResponse]
    def exec_api(agent, operation, params)

      # temporary workaround for supporting both protocols
      ver = agent.semver
      if !ver || ver <= ::SemVer.parse("v0.1.19") then
        # using old API
        return exec_api_http(agent, operation, params)
      end


      # execute using newer API
      begin
        return Bixby::AgentRegistry.execute(agent, JsonRequest.new(operation, params))

      rescue Exception => ex
        ret = JsonResponse.new("fail", ex.message, ex.backtrace)
        logger.warn { ex }
        return ret
      end
    end

    # Execute an API call using the deprecated HTTP API
    #
    # @param [Agent] agent
    # @param [String] operation
    # @param [*Array] params
    #
    # @return [JsonResponse]
    #
    # @deprecated Only works with Agent <= 0.17. Use {#exec_api} instead
    def exec_api_http(agent, operation, params)
      begin
        uri = agent.uri
        post = JsonRequest.new(operation, params)
        logger.debug { "uri: " + uri }
        logger.debug { post.to_s }

        if crypto_enabled? then
          ret = http_post(uri, encrypt_for_agent(agent, post.to_json))
          res = decrypt_from_agent(agent, ret)
        else
          res = http_post_json(uri, post.to_json)
        end

        ret = JsonResponse.from_json(res)
        logger.debug { ret.to_s }
        return ret

      rescue Curl::Err::CurlError => ex
        ret = JsonResponse.new("fail", ex.message, ex.backtrace)
        logger.warn { ex }
        return ret
      end
    end

  end

end # RemoteExec

class API
  include RemoteExec::Methods
end

end # Bixby
