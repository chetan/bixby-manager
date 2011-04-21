
require 'http_client'

class Agent < ActiveRecord::Base

    # validations
    validates_presence_of :port, :uuid, :public_key
    validates_uniqueness_of :uuid, :public_key

    include HttpClient

    # execute the given command and return the response
    def run_cmd(cmd)
        req = JsonRequest.new("exec", cmd.to_hash)
        res = JsonResponse.from_json(http_post_json(agent_uri, req.to_json))
    end

    def agent_uri
        "http://#{self.ip}:#{self.port}/"
    end

end
