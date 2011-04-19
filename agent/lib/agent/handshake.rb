
require 'ohai'
require 'uuidtools'

require AGENT_ROOT + "/agent/crypto"
require AGENT_ROOT + "/server/rpc"

module Handshake

    include Crypto

    def deregister_agent
        # TODO send dereg request
    end

    def register_agent
        req = JsonRequest.new("register", { :uuid => @uuid, :public_key => self.public_key.to_s })
        url = create_url("/agent/register")
        res = http_post_json(url, req.to_json)
        p res
    end

    def mac_changed?
        (not @mac_address.nil? and (@mac_address != get_mac_address()))
    end

    def get_mac_address
        o = Ohai::System.new
        o.require_plugin("os")
        o.require_plugin("network")
        addrs = o[:network][:interfaces][ o[:network][:default_interface] ]["addresses"]
        raise "Unable to find MAC address" if addrs.nil?
        ret = addrs.find{ |k,v| v["family"] == "lladdr" }
        raise "Unable to find MAC address" if ret.nil? or ret.empty?
        ret.first # got it!
    end

    def create_uuid
        UUIDTools::UUID.random_create.hexdigest
    end

end
