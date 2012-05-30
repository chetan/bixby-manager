
module Bixby

# Base class for all APIs
#
# @abstract
# @attr [ActionDispatch::Request] http_request  HTTP Request object
# @attr [JsonRequest] json_request  The original JsonRequest object
class API

  class Error < Exception
  end

  attr_accessor :http_request, :json_request

  # @param [ActionDispatch::Request] http_req   HTTP Request object
  # @param [JsonRequest] json_req               The original JsonRequest object
  def initialize(http_req = nil, json_req = nil)
    @http_request = http_req
    @json_request = json_req
  end


  protected

  # Helper for retrieving a model using flexible inputs
  #
  # @param [Object] obj       Can be Fixnum, String or Object (AR model instance)
  # @param [Class] clazz      AR type that is expected
  def get_model(obj, clazz)
    return clazz.find(obj.to_i) if [Fixnum, String].include? obj.class
    return obj
  end
end

end # Bixby
