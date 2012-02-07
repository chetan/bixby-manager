
module Inventory

    class << self

        def register_agent(request, params)

            tenant = Tenant.where("password = md5(?)", params[:password]).first
            if tenant.blank? then
                return JsonResponse.new(:fail, "password didn't match any known tenants")
            end
            org = Org.where(:tenant_id => tenant.id, :name => 'default').first

            h = Host.new
            h.org_id = org.id
            h.ip = request.remote_ip
            h.hostname = nil # TODO reverse lookup ip
            h.save!

            a = Agent.new
            a.host_id = h.id
            a.ip = request.remote_ip
            a.port = params[:port]
            a.uuid = params[:uuid]
            a.public_key = params[:public_key]

            if not a.valid? then
                # validate this agent first
                msg = ""
                a.errors.keys.each { |k| msg += "; " if not msg.empty?; msg += "#{k}: #{a.errors[k]}" }
                return JsonResponse.new(:fail, msg)
            end

            a.save!

            return nil
        end

    end # self

end
