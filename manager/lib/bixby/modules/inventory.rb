
module Bixby

class Inventory < API

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

end

end # Bixby
