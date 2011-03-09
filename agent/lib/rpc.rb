
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

    attr_accessor :status, :message, :data, :code

    def initialize(status = nil, message = nil, data = nil, code = nil)
        @status = status
        @message = message
        @data = data
        @code = code
    end

    def self.invalid_request(msg = nil)
        new("fail", (msg || "invalid request"), nil, 400)
    end

    def self.package_not_found(package)
        new("fail", "package not found: #{package}", nil, 404)
    end
end
