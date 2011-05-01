
require 'util/http_client'

class Agent < ActiveRecord::Base

    STATUS_NEW      = 0
    STATUS_ACTIVE   = 1
    STATUS_INACTIVE = 2

    # validations
    validates_presence_of :port, :uuid, :public_key
    validates_uniqueness_of :uuid, :public_key

    include HttpClient

    # execute the given command and return the response
    def run_cmd(cmd)
        req = JsonRequest.new("exec", cmd.to_hash)
        return req.exec()
    end

    def agent_uri
        "http://#{self.ip}:#{self.port}/"
    end

end
