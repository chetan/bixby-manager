
require 'ohai'
require 'ezcrypto'
require 'ezsig'
require 'uuidtools'

module Handshake

    def deregister_agent
        # TODO send dereg request
    end

    def register_agent
        url = "http://#{manager_ip}:#{manager_port}/agent/register?ip=#{agent_ip}&uuid=#{agent_uuid}"
        puts url
        puts http_get(url)
    end

    def mac_changed?
        (not @agent_mac.nil? and (@agent_mac != get_mac_address()))
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

    # create crypto keypair and save in config folder
    def create_keypair
        pair = EzCrypto::Signer.generate
        File.open(File.join(self.config_dir, "id_rsa"), 'w') { |out| out.write(pair.private_key.to_s) }
        File.open(File.join(self.config_dir, "id_rsa.pub"), 'w') { |out| out.write(pair.public_key.to_s) }
    end

    def create_uuid
        UUIDTools::UUID.random_create.hexdigest
    end
end
