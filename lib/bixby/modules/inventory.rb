
module Bixby

class Inventory < API

  METADATA_FACTER = 3

  # Register an Agent with the server. Also creates an associated Host record
  #
  # @param [String] uuid
  # @param [String] public_key
  # @param [String] hostname
  # @param [FixNum] port
  # @param [String] tenant      Name of the tenant
  # @param [String] password    Password for registering an Agent with the server
  def register_agent(uuid, public_key, hostname, port, tenant, password)

    t = Tenant.where(:name => tenant).first
    if t.blank? || !t.test_password(password) then
      # TODO log more detailed info?
      raise API::Error, "bad tenant and/or password", caller
    end

    # TODO pass org as param
    # for now, assign to default org
    org = Org.where(:tenant_id => t.id, :name => 'default').first
    if org.nil? then
      # TODO log more detailed info?
      raise API::Error, "bad tenant and/or password", caller
    end

    h = Host.new
    h.org_id = org.id
    h.ip = @http_request.ip
    h.hostname = hostname
    h.tag_list = "new"
    h.save!

    a = Agent.new
    a.host_id = h.id
    a.ip = h.ip
    a.port = port
    a.uuid = uuid
    a.public_key = public_key
    a.access_key = Bixby::CryptoUtil.generate_access_key
    a.secret_key = Bixby::CryptoUtil.generate_secret_key

    if not a.valid? then
      # validate this agent first
      msg = ""
      a.errors.keys.each { |k| msg += "; " if not msg.empty?; msg += "#{k}: #{a.errors[k]}" }
      raise API::Error, msg, caller
    end

    a.save!

    { :server_key => server_key_for_agent(a).public_key.to_s,
      :access_key => a.access_key,
      :secret_key => a.secret_key }
  end

  # Update Facter facts on the given Host or Agent
  #
  # @param [Host] host      to update
  def update_facts(host)

    if host.kind_of? Agent then
      agent = host
    else
      host = get_model(host, Host)
      agent = host.agent
    end

    command = CommandSpec.new( :repo => "vendor", :bundle => "system/inventory",
                               :command => "list_facts.rb" )

    ret = exec(agent, command)
    if ret.error? then
      return ret # TODO
    end

    ActiveRecord::Base.transaction do
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
    end

    true
  end

end

end # Bixby
