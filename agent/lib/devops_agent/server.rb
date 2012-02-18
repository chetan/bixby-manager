
require 'sinatra/base'

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
        return JsonResponse.invalid_request.to_json
    end

    post '/*' do
        @log.debug { "POST: #{request.path}" }

        req = extract_valid_request()
        if req.kind_of? String then
            @log.debug { "received a String; returning" }
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
            return JsonResponse.invalid_request.to_json
        end

        begin
            req = JsonRequest.from_json(body)
        rescue Exception => ex
            return JsonResponse.invalid_request.to_json
        end

        if not SUPPORTED_OPERATIONS.include? req.operation then
            return JsonResponse.invalid_request("unsupported operation: #{req.operation}").to_json
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
                return JsonResponse.bundle_not_found(ex.message).to_json
            elsif ex.kind_of? CommandNotFound then
                return JsonResponse.command_not_found(ex.message).to_json
            end
            @log.error(ex)
            return JsonResponse.new("fail", ex.message, nil, 500).to_json
        end
        data = { :result => status.exitstatus, :stdout => stdout, :stderr => stderr }
        return JsonResponse.new("success", nil, data).to_json
    end

end
