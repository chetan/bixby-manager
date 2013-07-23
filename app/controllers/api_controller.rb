
require 'bixby/modules/provisioning'
require 'bixby/modules/inventory'
require 'bixby/file_download'

class ApiController < ApplicationController

  include Bixby::Crypto

  skip_before_filter :verify_authenticity_token

  def handle

    begin

      @agent = nil
      ret = handle_request()

      # return response
      if ret.kind_of? Bixby::FileDownload then
        return send_file(ret.filename, :filename => File.basename(ret.filename))

      elsif ret.kind_of? Bixby::JsonResponse then
        return render(:json => ret.to_json)
      end

      return render(:json => Bixby::JsonResponse.new(:success, nil, ret).to_json)

    rescue Exception => ex
      logger.warn { ex }
      return render(:json => Bixby::JsonResponse.new(:fail, ex.message, ex, 500).to_json)
    end

  end # handle


  private

  # Handle the API request
  #
  # @return [Object, JsonResponse] response can be either a JsonResponse or any other type
  def handle_request

    # extract JsonRequest

    json_req = extract_request()
    return json_req if json_req.kind_of? Bixby::JsonResponse


    # validate request of form: operation = "module_name:method_name"

    mod = op = nil
    if json_req.operation.include? ":" then
      (mod, op) = json_req.operation.split(/:/)
    end

    if mod.blank? or op.blank? then
      return unsupported_operation(json_req)
    end

    begin
      mod = "Bixby::#{mod.camelize}"
      mod = mod.constantize.new(request, json_req)
      op = op.to_sym
      if not(mod and mod.respond_to? op) then
        return unsupported_operation(json_req)
      end
    rescue Exception => ex
      return unsupported_operation(json_req)
    end


    # authenticate the request but still allow agent registration (which will not be signed)
    if decrypt?(mod, op) then
      @agent = Agent.where(:access_key => ApiAuth.access_id(request)).first
      if not(@agent and ApiAuth.authentic?(request, @agent.secret_key)) then
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

  end # handle_request()

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

  # Extract JsonRequest from the POST body
  #
  # @return [JsonRequest]
  def extract_request

    # not sure why we need to rewind first, but we do. some change introduced in rails4
    request.body.rewind if request.body.respond_to?(:rewind)
    body = request.raw_post.strip
    if body.blank? then
      return Bixby::JsonResponse.invalid_request
    end

    begin
      json_req = Bixby::JsonRequest.from_json(body)
    rescue Exception => ex
      return Bixby::JsonResponse.invalid_request
    end

    if json_req.operation.blank? then
      return Bixby::JsonResponse.invalid_request
    end

    return json_req
  end

end # ApiController
