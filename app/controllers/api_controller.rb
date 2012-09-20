
require 'bixby/modules/provisioning'
require 'bixby/modules/inventory'
require 'bixby/file_download'

class ApiController < ApplicationController

  skip_before_filter :verify_authenticity_token

  def handle

    begin

      ret = handle_request()

      # return response
      if ret.kind_of? Bixby::FileDownload then
        return send_file(ret.filename, :filename => File.basename(ret.filename))

      elsif ret.kind_of? Bixby::JsonResponse then
        return render(:json => ret.to_json)
      end

      return render(:json => Bixby::JsonResponse.new(:success, nil, ret).to_json)

    rescue Exception => ex
      puts ex
      puts ex.backtrace
      return render(:json => Bixby::JsonResponse.new(:fail, ex.message, ex, 500).to_json)
    end

  end # handle


  private

  # Handle the API request
  #
  # @return [JsonResponse]
  def handle_request

    # extract JsonRequest

    req = extract_request()
    return req if req.kind_of? Bixby::JsonResponse


    # validate request of form: operation = "module_name:method_name"

    mod = op = nil
    if req.operation.include? ":" then
      (mod, op) = req.operation.split(/:/)
    end

    if mod.blank? or op.blank? then
      return unsupported_operation(req)
    end

    begin
      mod = "Bixby::#{mod.camelize}"
      mod = mod.constantize.new(request, req)
      op = op.to_sym
      if not (mod and mod.respond_to? op) then
        return unsupported_operation(req)
      end
    rescue Exception => ex
      return unsupported_operation(req)
    end


    # execute request

    # req = http request object
    if req.params.kind_of? Hash then
      return mod.send(op, HashWithIndifferentAccess.new(req.params))
    elsif req.params.kind_of? Array then
      return mod.send(op, *req.params)
    else
      return mod.send(op, req.params)
    end

  end # handle_request()

  # Helper for creating JsonResponse
  #
  # @param [JsonRequest] req
  #
  # @return [JsonResponse]
  def unsupported_operation(req)
    Bixby::JsonResponse.invalid_request("unsupported operation: '#{req.operation}'")
  end

  # Extract JsonRequest from the POST body
  #
  # @return [JsonRequest]
  def extract_request

    body = request.body.read.strip
    if body.blank? then
      return Bixby::JsonResponse.invalid_request
    end

    begin
      req = Bixby::JsonRequest.from_json(body)
    rescue Exception => ex
      return Bixby::JsonResponse.invalid_request
    end

    if req.operation.blank? then
      return Bixby::JsonResponse.invalid_request
    end

    return req
  end

end # ApiController
