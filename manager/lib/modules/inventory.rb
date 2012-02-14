
class Inventory < API

  def register_agent(uuid, public_key, hostname, port, password)

    tenant = Tenant.where("password = md5(?)", password).first
    if tenant.blank? then
      return JsonResponse.new(:fail, "password didn't match any known tenants")
    end

    # TODO pass org as param
    org = Org.where(:tenant_id => tenant.id, :name => 'default').first

    h = Host.new
    h.org_id = org.id
    h.ip = @http_request.remote_ip
    h.hostname = nil # TODO reverse lookup ip
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
      return JsonResponse.new(:fail, msg)
    end

    a.save!

    return nil
  end

end
