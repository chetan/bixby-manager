
require 'facter'
require 'uuidtools'

require "api/json_request"
require "api/json_response"

require "agent/crypto"

module Handshake

    include Crypto

    def deregister_agent
        # TODO send dereg request
    end

    def register_agent
        return Inventory.register_agent(@uuid, self.public_key.to_s, @port)
    end

    def mac_changed?
        (not @mac_address.nil? and (@mac_address != get_mac_address()))
    end

    def get_mac_address
        return @mac if not @mac.nil?
        Facter.collection.loader.load(:ipaddress)
        Facter.collection.loader.load(:interfaces)
        Facter.collection.loader.load(:macaddress)
        vals = Facter.collection.to_hash
        ip = vals["ipaddress"]
        raise "Unable to find MAC address" if ip.nil?
        int = vals.find{ |k,v| v == ip }[0].split(/_/)[1]
        raise "Unable to find MAC address" if int.nil? or int.empty?
        @mac = vals.find{ |k,v| k == "macaddress_#{int}" }[1]
    end

    def create_uuid
        UUIDTools::UUID.random_create.hexdigest
    end

end
