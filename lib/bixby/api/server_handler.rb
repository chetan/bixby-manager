
require "bixby/modules/crypto"

module Bixby

  # Process API requests from clients
  #
  # Clients could be either Agents or other API clients (command line tools, etc)
  class ServerHandler < Bixby::RpcHandler

    include Bixby::Log
    include Bixby::Crypto

    def initialize(request)
      @request = request
    end

    def handle(json_req)

      ret = handle_internal(json_req)
      if ret.kind_of? Bixby::JsonResponse or ret.kind_of? Bixby::FileDownload then
        return ret
      end

      return Bixby::JsonResponse.new(:success, nil, ret)

    end

    def connect(json_req, api)
      valid = validate_request(json_req)
      return valid if valid.kind_of? JsonResponse

      Bixby::AgentRegistry.add(@agent, api)
    end

    def disconnect(api)
      Bixby::AgentRegistry.remove(api)
    end


    private

    def handle_internal(json_req)

      # validate request of form: operation = "module_name:method_name"

      mod = op = nil
      if json_req.operation.include? ":" then
        (mod, op) = json_req.operation.split(/:/)
      end

      if mod.blank? or op.blank? then
        return unsupported_operation(json_req)
      end

      begin
        mod = find_module(mod).new(@request, json_req)
        op  = op.to_sym
        if not(mod and mod.respond_to? op) then
          return unsupported_operation(json_req)
        end
      rescue Exception => ex
        logger.error ex
        return unsupported_operation(json_req)
      end


      # authenticate the request but still allow agent registration (which will not be signed)
      if decrypt?(mod, op) then
        valid = validate_request(json_req)
        return valid if valid.kind_of? JsonResponse
      end


      # execute request

      if Bixby.is_async? mod.class, op then
        Bixby.do_async(mod.class, op, json_req.params)
        return nil
      end

      if decrypt?(mod, op) then
        # set tenant now so we can process the request securely
        MultiTenant.current_tenant = @agent.tenant
      end

      method = mod.method(op)

      if method.arity == 0 then
        # handle methods which should not have any params passed in
        if json_req.params.nil? then
          return mod.send(op)
        else
          return Bixby::JsonResponse.invalid_request("wrong number of arguments (#{json_req.params.size} for 0)")
        end

      elsif json_req.params.kind_of? Hash then
        return mod.send(op, HashWithIndifferentAccess.new(json_req.params))

      elsif json_req.params.kind_of? Array then
        return mod.send(op, *json_req.params)

      else
        return mod.send(op, json_req.params)

      end

    end # handle_internal

    # Validate the given request
    #
    # @param [JsonRequest] json_req
    #
    # @return [Bixby::JsonResponse] if request fails validation
    # @return [Boolean] true if success
    def validate_request(json_req)

      if @request.kind_of? Bixby::WebSocket::Request then
        signed_request = SignedJsonRequest.new(json_req)
        signed_request.body = @request.body
        signed_request.headers = @request.headers
      else
        signed_request = @request
      end

      @agent = Agent.where(:access_key => ApiAuth.access_id(signed_request)).first
      if not(@agent and ApiAuth.authentic?(signed_request, @agent.secret_key)) then
        return Bixby::JsonResponse.new("fail", "authentication failed", nil, 401)
      end

      return true
    end

    # Find a Bixby module with the given name
    #
    # @param [String] str
    #
    # @return [Class] class object
    # @raise  [NameError]
    def find_module(str)
      begin
        return "Bixby::#{str}".constantize
      rescue NameError
      end
      return "Bixby::#{str.camelize}".constantize
    end

    # Test whether or not this request should be decrypted
    #
    # @param [Bixby::API] mod     module
    # @param [Symbol] op          method name
    #
    # @return [Boolean]
    def decrypt?(mod, op)
      crypto_enabled? and !(mod.kind_of? Bixby::Inventory and op == :register_agent)
    end

    # Helper for creating JsonResponse
    #
    # @param [JsonRequest] json_req
    #
    # @return [JsonResponse]
    def unsupported_operation(json_req)
      Bixby::JsonResponse.invalid_request("unsupported operation: '#{json_req.operation}'")
    end

  end

end
