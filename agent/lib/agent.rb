
require 'uuidtools'
require 'uri'

require AGENT_ROOT + "/operation"
require AGENT_ROOT + "/http_client"
require AGENT_ROOT + "/handshake"
require AGENT_ROOT + "/remote_exec"
require AGENT_ROOT + "/config"

class Agent

    DEFAULT_ROOT_DIR = "/opt/devops"

    include HttpClient
    include Config
    include Handshake
    include RemoteExec

    class << self
        attr_accessor :agent_root
    end

    def agent_root
        self.class.agent_root
    end

    def agent_root=(path)
        self.class.agent_root = path
    end

    attr_accessor :manager_uri, :uuid, :mac_address

    def self.create(uri = nil, root_dir = nil, use_config = true)

        agent = load_config(root_dir) if use_config

        if agent.nil? and (uri.nil? or URI.parse(uri).nil?) then
            raise "Missing manager URI"
        end

        return agent if not agent.nil?
        return new(uri, root_dir)
    end

    private_class_method :new

    def initialize(uri, root_dir = nil)
        @new = true

        @manager_uri = uri
        @agent_root = root_dir.nil? ? DEFAULT_ROOT_DIR : root_dir

        @uuid = create_uuid()
        @mac_address = get_mac_address()
        create_keypair()
    end

end

