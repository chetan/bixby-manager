
class Agent < ActiveRecord::Base

    # validations
    validates_presence_of :port, :uuid, :public_key
    validates_uniqueness_of :uuid, :public_key

    def run_cmd(name)

        # puts Curl::Easy.http_get("http://#{ip}:4567/uptime").body_str
        ret = Curl::Easy.http_get("http://#{ip}:4567/op/#{name}").body_str

    end

end
