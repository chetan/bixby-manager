
require File.join(File.expand_path(File.dirname(__FILE__)), "/bootstrap")

require "uri"

require "logging"

require "bixby_agent/config_exception"
require "bixby_agent/agent/handshake"
require "bixby_agent/agent/remote_exec"
require "bixby_agent/agent/api"
require "bixby_agent/agent/config"

module Bixby
class Agent

  DEFAULT_ROOT_DIR = "/opt/devops"

  include HttpClient
  include Config
  include Handshake
  include RemoteExec
  include API

  class << self
    attr_accessor :agent_root
  end

  def agent_root
    self.class.agent_root
  end

  def agent_root=(path)
    self.class.agent_root = path
  end

  attr_accessor :port, :manager_uri, :uuid, :mac_address, :password, :log

  def self.create(uri = nil, password = nil, root_dir = nil, port = nil, use_config = true)

    agent = load_config(root_dir) if use_config

    if agent.nil? and (uri.nil? or URI.parse(uri).nil?) then
      raise ConfigException, "Missing manager URI", caller
    end

    if agent.nil? then
      # create a new one if unable to load
      uri = uri.gsub(%r{/$}, '') # remove trailing slash
      agent = new(uri, password, root_dir, port)
    end

    # pass config to some modules
    BundleRepository.path = File.join(agent.agent_root, "/repo")
    BaseModule.agent = agent
    BaseModule.manager_uri = agent.manager_uri
    ENV["BIXBY_HOME"] = agent.agent_root

    return agent
  end

  def initialize(uri, password = nil, root_dir = nil, port = nil)
    @new = true

    @log = Logging.logger[self]

    @port = port
    @manager_uri = uri
    @password = password
    @agent_root = root_dir.nil? ? DEFAULT_ROOT_DIR : root_dir

    @uuid = create_uuid()
    @mac_address = get_mac_address()
    create_keypair()
  end
  private_class_method :new

end # Agent
end # Bixby
