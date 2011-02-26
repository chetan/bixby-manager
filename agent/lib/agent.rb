
require File.dirname(__FILE__) + "/operation"
require File.dirname(__FILE__) + "/http_client"
require File.dirname(__FILE__) + "/handshake"
require File.dirname(__FILE__) + "/provisioning"

class Agent

  include HttpClient
  include Handshake
  include Provisioning

  attr_accessor :manager_ip, :manager_port
  attr_accessor :agent_uuid, :agent_ip, :agent_root

  def initialize
    @manager_ip = '192.168.44.99'
    @manager_port = 3000

    @agent_uuid = 12345
    @agent_ip = '192.168.44.109'
    @agent_root = '/opt/devops/'
  end

end

