
require 'uuidtools'

require File.dirname(__FILE__) + "/operation"
require File.dirname(__FILE__) + "/http_client"
require File.dirname(__FILE__) + "/handshake"
require File.dirname(__FILE__) + "/provisioning"
require File.dirname(__FILE__) + "/config"

class Agent

    DEFAULT_ROOT_DIR = "/opt/devops"
    @agent_root = DEFAULT_ROOT_DIR # TODO set via command line

    include HttpClient
    include Config
    include Handshake
    include Provisioning

    class << self
        attr_accessor :agent_root
    end

    attr_accessor :manager_ip, :manager_port
    attr_accessor :uuid, :agent_ip, :agent_root, :mac_address

    def self.create(use_config = true)
        agent = load_config() if use_config
        return agent if not agent.nil?
        return new()
    end

    private_class_method :new

    def initialize
        @new = true

        @manager_ip = '192.168.80.99'
        @manager_port = 3000

        @uuid = create_uuid()
        @agent_ip = '192.168.80.99'

        @mac_address = get_mac_address()
        create_keypair()
    end

end

