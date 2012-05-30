
module Bixby

class Inventory < API

  METADATA_FACTER = 3

  # Register an Agent with the server. Also creates an associated Host record
  #
  # @param [String] uuid
  # @param [String] public_key
  # @param [String] hostname
  # @param [FixNum] port
  # @param [String] password  Password for registering an Agent with the server
  def register_agent(uuid, public_key, hostname, port, password)

    tenant = Tenant.where("password = md5(?)", password).first
    if tenant.blank? then
      raise API::Error, "password didn't match any known tenants", caller
    end

    # TODO pass org as param
    org = Org.where(:tenant_id => tenant.id, :name => 'default').first
    if org.nil? then
      raise API::Error, "org not found", caller
    end

    h = Host.new
    h.org_id = org.id
    h.ip = @http_request.remote_ip
    h.hostname = hostname
    h.save!

    a = Agent.new
    a.host_id = h.id
    a.ip = @http_request.remote_ip
    a.port = port
    a.uuid = uuid
    a.public_key = public_key

    if not a.valid? then
      # validate this agent first
      msg = ""
      a.errors.keys.each { |k| msg += "; " if not msg.empty?; msg += "#{k}: #{a.errors[k]}" }
      raise API::Error, msg, caller
    end

    a.save!

    a
  end

  # Update Facter facts on the given Agent
  #
  # @param [Agent] agent
  def update_facts(agent)

    agent = get_model(agent, Agent)

    command = CommandSpec.new( :repo => "vendor", :bundle => "system/inventory",
                               :command => "list_facts.rb" )

    ret = exec(agent, command)
    if ret.error? then
      return ret # TODO
    end

    facts = ret.decode
    metadata = {}

    agent.host.metadata ||= []
    agent.host.metadata.each { |m| metadata["#{m.key}_#{m.source}"] = m }

    facts.each do |k,v|
      mk = "#{k}_#{METADATA_FACTER}"
      if metadata.include?(mk) then
        metadata[mk].value = v
      else
        m = Metadata.for(k, v, METADATA_FACTER)
        agent.host.metadata << m
      end
    end

    agent.host.save!

    true
  end

end

end # Bixby
