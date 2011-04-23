
require File.join(File.expand_path(File.dirname(__FILE__)), "/bootstrap")

require 'uri'

require "util/http_client"

require "agent/handshake"
require "agent/remote_exec"
require "agent/config"

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

    attr_accessor :port, :manager_uri, :uuid, :mac_address

    def self.create(uri = nil, root_dir = nil, port = nil, use_config = true)

        agent = load_config(root_dir) if use_config

        if agent.nil? and (uri.nil? or URI.parse(uri).nil?) then
            raise "Missing manager URI"
        end

        return agent if not agent.nil?
        return new(uri, root_dir, port)
    end

    private_class_method :new

    def initialize(uri, root_dir = nil, port = nil)
        @new = true

        @port = port
        @manager_uri = uri
        @agent_root = root_dir.nil? ? DEFAULT_ROOT_DIR : root_dir

        @uuid = create_uuid()
        @mac_address = get_mac_address()
        create_keypair()
    end

end

