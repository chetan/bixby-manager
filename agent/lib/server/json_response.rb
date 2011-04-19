
require AGENT_ROOT + "/util/jsonify"

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

    def self.command_not_found(command)
        new("fail", "command not found: #{command}", nil, 404)
    end
end
