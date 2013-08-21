
require "bixby/modules/crypto"

module Bixby

  class ServerHandler < Bixby::RpcHandler

    include Bixby::Log
    include Bixby::Crypto

    def initialize(http_request)
      @http_request = http_request
    end

    def handle(json_req)

      ret = handle_internal(json_req)
      if ret.kind_of? Bixby::JsonResponse or ret.kind_of? Bixby::FileDownload then
        return ret
      end

      return Bixby::JsonResponse.new(:success, nil, ret)

    end


    private

    def handle_internal(json_req)

      # validate request of form: operation = "module_name:method_name"

      mod = op = nil
      if json_req.operation.include? ":" then
        (mod, op) = json_req.operation.split(/:/)
      end

      if mod.blank? or op.blank? then
        logger.warn "returning unsupported"
        return unsupported_operation(json_req)
      end

      begin
        mod = "Bixby::#{mod.camelize}"
        mod = mod.constantize.new(@http_request, json_req)
        op = op.to_sym
        logger.debug op
        if not(mod and mod.respond_to? op) then
          logger.warn "returning unsupported 2"
          return unsupported_operation(json_req)
        end
      rescue Exception => ex
        logger.warn "returning unsupported 3"
        logger.error ex
        return unsupported_operation(json_req)
      end


      # authenticate the request but still allow agent registration (which will not be signed)
      if decrypt?(mod, op) then
        @agent = Agent.where(:access_key => ApiAuth.access_id(@http_request)).first
        if not(@agent and ApiAuth.authentic?(@http_request, @agent.secret_key)) then
          return Bixby::JsonResponse.new("fail", "authentication failed", nil, 401)
        end
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

      if json_req.params.kind_of? Hash then
        return mod.send(op, HashWithIndifferentAccess.new(json_req.params))
      elsif json_req.params.kind_of? Array then
        return mod.send(op, *json_req.params)
      else
        return mod.send(op, json_req.params)
      end
    end # handle_internal

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
