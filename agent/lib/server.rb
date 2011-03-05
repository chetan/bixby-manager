
require 'sinatra/base'

require File.dirname(__FILE__) + "/rpc"

class Server < Sinatra::Base

    class << self
        attr_accessor :agent
    end

    def agent
        self.class.agent
    end

    get '/*' do
        return JsonResponse.invalid_request.to_json
    end

    post '/*' do

        body = request.body.read.strip
        if body.blank? then
            return JsonResponse.invalid_request.to_json
        end

        begin
            req = JsonRequest.from_json(body)
        rescue Exception => ex
            return JsonResponse.invalid_request.to_json
        end

        if req.operation != "exec" then
            return JsonResponse.invalid_request("unsupported operation").to_json
        end

        ret = agent.exec(req.params)
        return ret.to_s
    end

end
