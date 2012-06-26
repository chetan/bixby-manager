
require 'facter'
require 'uuidtools'

require "bixby_agent/agent/crypto"

module Bixby
class Agent

module Handshake

  include Crypto

  def deregister_agent
    # TODO send dereg request
  end

  def register_agent
    params = [ @uuid, self.public_key.to_s, get_hostname(), @port, @password ]
    req = JsonRequest.new("inventory:register_agent", params)
    return exec_api(req)
  end

  def mac_changed?
    (not @mac_address.nil? and (@mac_address != get_mac_address()))
  end

  def get_hostname
    `hostname`.strip
  end

  def get_mac_address
    return @mac if not @mac.nil?
    Facter.collection.loader.load(:ipaddress)
    Facter.collection.loader.load(:interfaces)
    Facter.collection.loader.load(:macaddress)
    vals = {}
    Facter.collection.list.each { |n| vals[n] = Facter.collection[n] }
    ip = vals[:ipaddress]
    raise "Unable to find IP address" if ip.nil?
    int = vals.find{ |k,v| v == ip && k != :ipaddress }.first.to_s.split(/_/)[1]
    raise "Unable to find primary interface" if int.nil? or int.empty?
    @mac = vals["macaddress_#{int}".to_sym]
  end

  def create_uuid
    UUIDTools::UUID.random_create.hexdigest
  end

end # Handshake

end # Agent
end # Bixby
