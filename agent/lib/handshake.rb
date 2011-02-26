
module Handshake

    def register_agent
        url = "http://#{manager_ip}:#{manager_port}/agent/register?ip=#{agent_ip}&uuid=#{agent_uuid}"
        puts url
        puts http_get(url)
    end

end
