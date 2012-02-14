
# Base class for all APIs
#
# @abstract
# @attr [ActionDispatch::Request] http_request  HTTP Request object
# @attr [JsonRequest] json_request  The original JsonRequest object

class API

  include RemoteExec

  attr_accessor :http_request, :json_request

  # @param [ActionDispatch::Request] http_request  HTTP Request object
  # @param [JsonRequest] json_request  The original JsonRequest object
  def initialize(http_req = nil, json_req = nil)
    @http_request = http_req
    @json_request = json_req
  end

end
