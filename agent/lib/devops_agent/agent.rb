
require File.join(File.expand_path(File.dirname(__FILE__)), "/bootstrap")

require "uri"

require "devops_agent/config_exception"
require "devops_agent/agent/handshake"
require "devops_agent/agent/remote_exec"
require "devops_agent/agent/config"

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

    attr_accessor :port, :manager_uri, :uuid, :mac_address, :password

    def self.create(uri = nil, password = nil, root_dir = nil, port = nil, use_config = true)

        agent = load_config(root_dir) if use_config

        if agent.nil? and (uri.nil? or URI.parse(uri).nil?) then
            raise ConfigException, "Missing manager URI", caller
        end

        # remove trailing slash
        uri.gsub!(%r{/$}, '')

        agent = new(uri, password, root_dir, port) if agent.nil? # create a new one if unable to load

        # pass config to some modules
        BundleRepository.path = File.join(agent.agent_root, "/repo")
        BaseModule.agent = agent
        BaseModule.manager_uri = agent.manager_uri

        return agent
    end

    private_class_method :new

    def initialize(uri, password = nil, root_dir = nil, port = nil)
        @new = true

        @port = port
        @manager_uri = uri
        @password = password
        @agent_root = root_dir.nil? ? DEFAULT_ROOT_DIR : root_dir

        @uuid = create_uuid()
        @mac_address = get_mac_address()
        create_keypair()
    end

end

