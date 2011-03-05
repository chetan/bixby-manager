
require File.dirname(__FILE__) + "/jsonify"

class JsonRequest

    include Jsonify

    attr_accessor :operation, :params

    def initialize(operation, params)
        @operation = operation
        @params = params
    end
end

class JsonResponse

    include Jsonify

    attr_accessor :result, :message, :data

    def initialize(result = nil, message = nil, data = nil)
        @result = result
        @message = message
        @data = data
    end
end
