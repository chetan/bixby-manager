
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
    attr_accessor :agent_uuid, :agent_ip, :agent_root, :agent_mac

    def self.create(use_config = true)
        agent = load_config() if use_config
        return agent if not agent.nil?
        return new()
    end

    private_class_method :new

    def initialize
        @manager_ip = '192.168.80.99'
        @manager_port = 3000

        @agent_uuid = 12345
        @agent_ip = '192.168.80.99'

        @agent_mac = get_mac_address()
        @new = true
    end

end

