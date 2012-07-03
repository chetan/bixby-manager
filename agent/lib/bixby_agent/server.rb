
require 'sinatra/base'

module Bixby
class Server < Sinatra::Base

  SUPPORTED_OPERATIONS = [ "exec" ]

  DEFAULT_PORT = 18000

  class << self
    attr_accessor :agent
  end

  def initialize
    super
    @log = Logging.logger[self]
  end

  def agent
    self.class.agent
  end

  get '/*' do
    @log.debug { "Disposing of GET request: #{request.path}" }
    return encrypt(JsonResponse.invalid_request.to_json)
  end

  post '/*' do
    return encrypt(handle_request().to_json)
  end

  def encrypt(json)
    agent.crypto_enabled? ? agent.encrypt_for_server(json) : json
  end

  def handle_request
    req = extract_valid_request()
    if req.kind_of? JsonResponse then
      @log.debug { "received a JsonResponse; returning" }
      return req
    end
    @log.debug{ "request: \n#{req.to_json}" }

    ret = handle_exec(req)
    @log.debug{ "response: \n#{ret}" }

    return ret
  end

  def extract_valid_request
    body = request.body.read.strip
    if body.nil? or body.empty? then
      return JsonResponse.invalid_request
    end

    if agent.crypto_enabled? then
      body = agent.decrypt_from_server(body)
    end

    begin
      req = JsonRequest.from_json(body)
    rescue Exception => ex
      return JsonResponse.invalid_request
    end

    if not SUPPORTED_OPERATIONS.include? req.operation then
      return JsonResponse.invalid_request("unsupported operation: #{req.operation}")
    end

    return req
  end

  # Handle the exec request and return the response
  #
  # @return [String] JsonResponse.to_json
  def handle_exec(req)
    begin
      status, stdout, stderr = agent.exec(req.params)
    rescue Exception => ex
      if ex.kind_of? BundleNotFound then
        return JsonResponse.bundle_not_found(ex.message)
      elsif ex.kind_of? CommandNotFound then
        return JsonResponse.command_not_found(ex.message)
      end
      @log.error(ex)
      return JsonResponse.new("fail", ex.message, nil, 500)
    end
    data = { :status => status.exitstatus, :stdout => stdout, :stderr => stderr }
    return JsonResponse.new("success", nil, data)
  end

end # Server
end # Bixby
